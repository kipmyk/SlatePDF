import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var viewModel = DocumentViewModel()
    @State private var showingFilePicker = false
    @State private var showingSavePanel = false
    @State private var editingPageIndex: Int?
    @State private var showingEditor = false
    
    var body: some View {
        HSplitView {
            // Left sidebar: Document list
            VStack(alignment: .leading, spacing: 12) {
                Text("Documents")
                    .font(.headline)
                    .padding(.horizontal)
                
                if viewModel.documents.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No documents loaded")
                            .foregroundColor(.secondary)
                        
                        Button("Open PDF") {
                            showingFilePicker = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.documents, selection: $viewModel.selectedDocumentID) { item in
                        DocumentRow(item: item)
                            .tag(item.id)
                    }
                    
                    HStack {
                        Button("Add PDF") {
                            showingFilePicker = true
                        }
                        
                        if viewModel.documents.count >= 2 {
                            Button("Merge All") {
                                viewModel.mergeSelectedDocuments()
                            }
                        }
                    }
                    .padding()
                }
            }
            .frame(minWidth: 200, idealWidth: 250)
            
            // Right side: Page grid and operations
            VStack(spacing: 0) {
                if let document = viewModel.selectedDocument {
                    // Toolbar
                    HStack {
                        Text(document.name)
                            .font(.headline)
                        
                        Spacer()
                        
                        Button("Edit Page") {
                            if let firstIndex = viewModel.selectedPageIndices.first {
                                editingPageIndex = firstIndex
                                showingEditor = true
                            } else {
                                editingPageIndex = 0
                                showingEditor = true
                            }
                        }
                        .disabled(viewModel.isProcessing)
                        
                        Button("Save") {
                            showingSavePanel = true
                        }
                        .disabled(viewModel.isProcessing)
                        
                        Button("Delete Selected") {
                            viewModel.deleteSelectedPages()
                        }
                        .disabled(viewModel.selectedPageIndices.isEmpty || viewModel.isProcessing)
                    }
                    .padding()
                    .background(Color(nsColor: .controlBackgroundColor))
                    
                    // Page grid
                    PageGridView(
                        document: document.document,
                        selectedIndices: $viewModel.selectedPageIndices,
                        onReorder: { from, to in
                            viewModel.reorderPage(from: from, to: to)
                        }
                    )
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("Select a document")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Status bar
                if let message = viewModel.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(message)
                            .foregroundColor(.red)
                        Spacer()
                        Button("Dismiss") {
                            viewModel.errorMessage = nil
                        }
                    }
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                } else if let message = viewModel.successMessage {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(message)
                            .foregroundColor(.green)
                        Spacer()
                        Button("Dismiss") {
                            viewModel.successMessage = nil
                        }
                    }
                    .padding(8)
                    .background(Color.green.opacity(0.1))
                }
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                for url in urls {
                    _ = url.startAccessingSecurityScopedResource()
                    viewModel.loadDocument(from: url)
                    url.stopAccessingSecurityScopedResource()
                }
            case .failure(let error):
                viewModel.errorMessage = error.localizedDescription
            }
        }
        .fileExporter(
            isPresented: $showingSavePanel,
            document: viewModel.selectedDocument.map { PDFDocumentWrapper(document: $0.document) },
            contentType: .pdf,
            defaultFilename: viewModel.selectedDocument?.name ?? "document"
        ) { result in
            switch result {
            case .success(let url):
                if let docID = viewModel.selectedDocumentID {
                    viewModel.saveDocument(id: docID, to: url)
                }
            case .failure(let error):
                viewModel.errorMessage = error.localizedDescription
            }
        }
        .sheet(isPresented: $showingEditor) {
            if let document = viewModel.selectedDocument,
               let pageIndex = editingPageIndex {
                PDFEditorView(
                    item: document,
                    selectedPageIndex: pageIndex
                )
                .frame(minWidth: 900, minHeight: 700)
            }
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

// Document row in sidebar
struct DocumentRow: View {
    @ObservedObject var item: PDFDocumentItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(.body)
            Text("\(item.document.pageCount) pages")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// Wrapper for file exporter
struct PDFDocumentWrapper: FileDocument {
    static var readableContentTypes: [UTType] = [.pdf]
    
    let document: PDFDocument
    
    init(document: PDFDocument) {
        self.document = document
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let doc = PDFDocument(data: data) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.document = doc
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = document.dataRepresentation() else {
            throw CocoaError(.fileWriteUnknown)
        }
        return FileWrapper(regularFileWithContents: data)
    }
}
