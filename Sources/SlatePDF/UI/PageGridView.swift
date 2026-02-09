import SwiftUI
import PDFKit

struct PageGridView: View {
    let document: PDFDocument
    @Binding var selectedIndices: Set<Int>
    let onReorder: (Int, Int) -> Void
    
    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(0..<document.pageCount, id: \.self) { index in
                    PageThumbnailView(
                        page: document.page(at: index),
                        index: index,
                        isSelected: selectedIndices.contains(index),
                        onSelect: {
                            toggleSelection(index)
                        }
                    )
                    .contextMenu {
                        Button("Delete") {
                            selectedIndices = [index]
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(nsColor: .textBackgroundColor))
    }
    
    private func toggleSelection(_ index: Int) {
        if selectedIndices.contains(index) {
            selectedIndices.remove(index)
        } else {
            selectedIndices.insert(index)
        }
    }
}

struct PageThumbnailView: View {
    let page: PDFPage?
    let index: Int
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            if let page = page {
                PDFPagePreview(page: page)
                    .frame(width: 150, height: 200)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 3 : 1)
                    )
                    .shadow(radius: 2)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 150, height: 200)
                    .cornerRadius(8)
            }
            
            Text("Page \(index + 1)")
                .font(.caption)
                .foregroundColor(isSelected ? .blue : .secondary)
        }
        .onTapGesture {
            onSelect()
        }
    }
}

// NSView wrapper for PDFPage rendering
struct PDFPagePreview: NSViewRepresentable {
    let page: PDFPage
    
    func makeNSView(context: Context) -> PDFPageView {
        PDFPageView(page: page)
    }
    
    func updateNSView(_ nsView: PDFPageView, context: Context) {
        nsView.page = page
    }
}

class PDFPageView: NSView {
    var page: PDFPage
    
    init(page: PDFPage) {
        self.page = page
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        // White background
        context.setFillColor(NSColor.white.cgColor)
        context.fill(bounds)
        
        // Draw PDF page
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
