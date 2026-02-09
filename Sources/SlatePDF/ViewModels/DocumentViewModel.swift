import Foundation
import PDFKit
import Combine

/// ViewModel managing PDF document state and operations
@MainActor
class DocumentViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var documents: [PDFDocumentItem] = []
    @Published var selectedDocumentID: UUID?
    @Published var selectedPageIndices: Set<Int> = []
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    // MARK: - Private Properties
    
    private var undoStack: [Operation] = []
    private var redoStack: [Operation] = []
    
    // MARK: - Computed Properties
    
    var selectedDocument: PDFDocumentItem? {
        documents.first { $0.id == selectedDocumentID }
    }
    
    var canUndo: Bool {
        !undoStack.isEmpty
    }
    
    var canRedo: Bool {
        !redoStack.isEmpty
    }
    
    // MARK: - Document Management
    
    func loadDocument(from url: URL) {
        isProcessing = true
        errorMessage = nil
        
        do {
            let document = try PDFValidator.validatePDFFile(at: url)
            let item = PDFDocumentItem(document: document, url: url)
            documents.append(item)
            selectedDocumentID = item.id
            successMessage = "Loaded \(url.lastPathComponent)"
        } catch {
            errorMessage = "Failed to load PDF: \(error.localizedDescription)"
        }
        
        isProcessing = false
    }
    
    func removeDocument(id: UUID) {
        documents.removeAll { $0.id == id }
        if selectedDocumentID == id {
            selectedDocumentID = documents.first?.id
        }
    }
    
    // MARK: - PDF Operations
    
    func mergeSelectedDocuments() {
        guard documents.count >= 2 else {
            errorMessage = "Need at least 2 documents to merge"
            return
        }
        
        isProcessing = true
        errorMessage = nil
        
        do {
            let mergedDoc = PDFDocument()
            let docsToMerge = documents.map { $0.document }
            try mergedDoc.mergePDFs(docsToMerge)
            
            let item = PDFDocumentItem(
                document: mergedDoc,
                url: nil,
                name: "Merged Document"
            )
            
            documents = [item]
            selectedDocumentID = item.id
            successMessage = "Successfully merged \(docsToMerge.count) documents"
            
            clearUndoRedoStacks()
        } catch {
            errorMessage = "Failed to merge: \(error.localizedDescription)"
        }
        
        isProcessing = false
    }
    
    func reorderPage(from sourceIndex: Int, to destinationIndex: Int) {
        guard let item = selectedDocument else { return }
        
        isProcessing = true
        errorMessage = nil
        
        do {
            // Save operation for undo
            let operation = Operation.reorder(
                documentID: item.id,
                from: sourceIndex,
                to: destinationIndex
            )
            undoStack.append(operation)
            redoStack.removeAll()
            
            try item.document.reorderPage(from: sourceIndex, to: destinationIndex)
            item.objectWillChange.send()
            successMessage = "Reordered page \(sourceIndex + 1) to position \(destinationIndex + 1)"
        } catch {
            errorMessage = "Failed to reorder: \(error.localizedDescription)"
        }
        
        isProcessing = false
    }
    
    func deleteSelectedPages() {
        guard let item = selectedDocument else { return }
        guard !selectedPageIndices.isEmpty else {
            errorMessage = "No pages selected"
            return
        }
        
        isProcessing = true
        errorMessage = nil
        
        do {
            // Save operation for undo
            let operation = Operation.delete(
                documentID: item.id,
                indices: selectedPageIndices
            )
            undoStack.append(operation)
            redoStack.removeAll()
            
            try item.document.deletePages(at: selectedPageIndices)
            item.objectWillChange.send()
            successMessage = "Deleted \(selectedPageIndices.count) page(s)"
            selectedPageIndices.removeAll()
        } catch {
            errorMessage = "Failed to delete: \(error.localizedDescription)"
        }
        
        isProcessing = false
    }
    
    // MARK: - File Operations
    
    func saveDocument(id: UUID, to url: URL) {
        guard let item = documents.first(where: { $0.id == id }) else { return }
        
        isProcessing = true
        errorMessage = nil
        
        do {
            try FileManager.default.safelySavePDF(item.document, to: url)
            item.url = url
            item.name = url.deletingPathExtension().lastPathComponent
            successMessage = "Saved to \(url.lastPathComponent)"
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
        }
        
        isProcessing = false
    }
    
    // MARK: - Undo/Redo
    
    func undo() {
        // Simplified undo - in production, this would restore previous state
        guard let operation = undoStack.popLast() else { return }
        redoStack.append(operation)
        // TODO: Implement actual undo logic
    }
    
    func redo() {
        // Simplified redo - in production, this would reapply operation
        guard let operation = redoStack.popLast() else { return }
        undoStack.append(operation)
        // TODO: Implement actual redo logic
    }
    
    private func clearUndoRedoStacks() {
        undoStack.removeAll()
        redoStack.removeAll()
    }
    
    // MARK: - Helper Types
    
    enum Operation {
        case reorder(documentID: UUID, from: Int, to: Int)
        case delete(documentID: UUID, indices: Set<Int>)
    }
}

/// Wrapper for PDFDocument with identity
class PDFDocumentItem: ObservableObject, Identifiable {
    let id = UUID()
    let document: PDFDocument
    var url: URL?
    var name: String
    
    init(document: PDFDocument, url: URL?, name: String? = nil) {
        self.document = document
        self.url = url
        self.name = name ?? url?.deletingPathExtension().lastPathComponent ?? "Untitled"
    }
}
