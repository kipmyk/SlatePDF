import SwiftUI
import PDFKit

struct PDFEditorView: View {
    @ObservedObject var item: PDFDocumentItem
    @State var selectedPageIndex: Int
    @Environment(\.dismiss) var dismiss
    @State private var showingTextInput = false
    @State private var showingImagePicker = false
    @State private var newText = ""
    @State private var fontSize: CGFloat = 16
    @State private var textColor: Color = .black
    @State private var annotations: [PDFAnnotation] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.cancelAction) // ESC key
                
                Spacer()
                
                // Page navigation
                Button {
                    if selectedPageIndex > 0 {
                        selectedPageIndex -= 1
                        loadAnnotations()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }
                .disabled(selectedPageIndex == 0)
                
                Text("Page \(selectedPageIndex + 1) of \(item.document.pageCount)")
                    .font(.headline)
                    .padding(.horizontal)
                
                Button {
                    if selectedPageIndex < item.document.pageCount - 1 {
                        selectedPageIndex += 1
                        loadAnnotations()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                }
                .disabled(selectedPageIndex >= item.document.pageCount - 1)
                
                Spacer()
                
                Button {
                    showingTextInput = true
                } label: {
                    Label("Add Text", systemImage: "text.cursor")
                }
                
                Button {
                    showingImagePicker = true
                } label: {
                    Label("Add Image", systemImage: "photo")
                }
                
                Button {
                    loadAnnotations()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                
                Button("Close") {
                    dismiss()
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            
            // PDF Page View
            if let page = item.document.page(at: selectedPageIndex) {
                let pageBounds = page.bounds(for: .mediaBox)
                ScrollView([.horizontal, .vertical]) {
                    PDFPageEditorView(
                        page: page,
                        onTap: { point in
                            if showingTextInput {
                                addText(at: point)
                                showingTextInput = false
                            }
                        }
                    )
                    .frame(width: pageBounds.width, height: pageBounds.height)
                }
            }
            
            // Annotations List
            if !annotations.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Annotations")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView {
                        VStack(spacing: 4) {
                            ForEach(annotations.indices, id: \.self) { index in
                                AnnotationRow(
                                    annotation: annotations[index],
                                    onDelete: {
                                        deleteAnnotation(at: index)
                                    }
                                )
                            }
                        }
                    }
                    .frame(maxHeight: 150)
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
            }
        }
        .sheet(isPresented: $showingTextInput) {
            TextInputSheet(
                text: $newText,
                fontSize: $fontSize,
                color: $textColor,
                onAdd: { point in
                    addText(at: point)
                }
            )
        }
        .fileImporter(
            isPresented: $showingImagePicker,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                addImage(from: url)
            }
        }
        .onAppear {
            print("📖 Editor opened with page index: \(selectedPageIndex) (Page \(selectedPageIndex + 1) of \(item.document.pageCount))")
            if let page = item.document.page(at: selectedPageIndex) {
                let bounds = page.bounds(for: .mediaBox)
                print("📐 Page dimensions: \(bounds.width) x \(bounds.height) pts")
            }
            loadAnnotations()
        }
    }
    
    private func addText(at point: CGPoint) {
        guard !newText.isEmpty else { return }
        
        do {
            try item.document.addTextAnnotation(
                text: newText,
                onPage: selectedPageIndex,
                at: point,
                fontSize: fontSize,
                color: NSColor(textColor)
            )
            newText = ""
            loadAnnotations()
            item.objectWillChange.send()
        } catch {
            print("Failed to add text: \(error)")
        }
    }
    
    private func addImage(from url: URL) {
        guard let image = NSImage(contentsOf: url) else { return }
        
        do {
            // Place image in center of page
            let rect = CGRect(x: 200, y: 300, width: 200, height: 200)
            try item.document.addImageAnnotation(
                image: image,
                onPage: selectedPageIndex,
                at: rect
            )
            loadAnnotations()
            item.objectWillChange.send()
        } catch {
            print("Failed to add image: \(error)")
        }
    }
    
    private func loadAnnotations() {
        do {
            annotations = try item.document.getAnnotations(onPage: selectedPageIndex)
        } catch {
            annotations = []
        }
    }
    
    private func deleteAnnotation(at index: Int) {
        guard index < annotations.count else { return }
        
        do {
            try item.document.removeAnnotation(annotations[index], fromPage: selectedPageIndex)
            loadAnnotations()
            item.objectWillChange.send()
        } catch {
            print("Failed to delete annotation: \(error)")
        }
    }
}

// Interactive PDF page view
struct PDFPageEditorView: NSViewRepresentable {
    let page: PDFPage
    let onTap: (CGPoint) -> Void
    
    func makeNSView(context: Context) -> PDFPageEditView {
        let view = PDFPageEditView(page: page, onTap: onTap)
        return view
    }
    
    func updateNSView(_ nsView: PDFPageEditView, context: Context) {
        nsView.page = page
    }
}

class PDFPageEditView: NSView {
    var page: PDFPage
    var onTap: (CGPoint) -> Void
    
    init(page: PDFPage, onTap: @escaping (CGPoint) -> Void) {
        self.page = page
        self.onTap = onTap
        super.init(frame: .zero)
        
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        self.addGestureRecognizer(clickGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleClick(_ gesture: NSClickGestureRecognizer) {
        let location = gesture.location(in: self)
        
        // Convert view coordinates to PDF coordinates
        let pageBounds = page.bounds(for: .mediaBox)
        let scale = min(bounds.width / pageBounds.width, bounds.height / pageBounds.height)
        
        let pdfX = location.x / scale
        let pdfY = pageBounds.height - (location.y / scale)
        
        onTap(CGPoint(x: pdfX, y: pdfY))
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        context.setFillColor(NSColor.white.cgColor)
        context.fill(bounds)
        
        context.saveGState()
        
        let pageBounds = page.bounds(for: .mediaBox)
        let scale = min(bounds.width / pageBounds.width, bounds.height / pageBounds.height)
        
        context.scaleBy(x: scale, y: scale)
        context.translateBy(x: 0, y: pageBounds.height)
        context.scaleBy(x: 1, y: -1)
        
        page.draw(with: .mediaBox, to: context)
        
        context.restoreGState()
    }
}

// Text input sheet
struct TextInputSheet: View {
    @Binding var text: String
    @Binding var fontSize: CGFloat
    @Binding var color: Color
    let onAdd: (CGPoint) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Add Text to PDF")
                .font(.headline)
            
            TextField("Enter text", text: $text)
                .textFieldStyle(.roundedBorder)
            
            HStack {
                Text("Font Size:")
                Slider(value: $fontSize, in: 8...72, step: 1)
                Text("\(Int(fontSize))")
                    .frame(width: 30)
            }
            
            ColorPicker("Text Color", selection: $color)
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Button("Add") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 400)
    }
}

// Annotation row
struct AnnotationRow: View {
    let annotation: PDFAnnotation
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: annotationIcon)
                .foregroundColor(.blue)
            
            Text(annotation.contents ?? "Annotation")
                .lineLimit(1)
            
            Spacer()
            
            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
    
    private var annotationIcon: String {
        // annotation.type is a String, not an enum
        if annotation.type == "FreeText" {
            return "text.cursor"
        } else if annotation.type == "Stamp" {
            return "photo"
        } else {
            return "note.text"
        }
    }
}
