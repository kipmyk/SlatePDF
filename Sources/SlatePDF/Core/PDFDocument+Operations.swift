import PDFKit
import Foundation

/// Extension providing safe PDF manipulation operations
extension PDFDocument {
    
    /// Error types for PDF operations
    enum PDFOperationError: LocalizedError {
        case invalidPageIndex(Int)
        case invalidPageRange(from: Int, to: Int)
        case emptyDocument
        case mergeFailure(String)
        case corruptedDocument
        
        var errorDescription: String? {
            switch self {
            case .invalidPageIndex(let index):
                return "Invalid page index: \(index)"
            case .invalidPageRange(let from, let to):
                return "Invalid page range: \(from) to \(to)"
            case .emptyDocument:
                return "Document is empty or has no pages"
            case .mergeFailure(let reason):
                return "Failed to merge PDFs: \(reason)"
            case .corruptedDocument:
                return "Document appears to be corrupted"
            }
        }
    }
    
    /// Validates that the document is not corrupt and has valid pages
    func validate() throws {
        guard pageCount > 0 else {
            throw PDFOperationError.emptyDocument
        }
        
        // Check if we can access first and last pages
        guard let _ = page(at: 0),
              let _ = page(at: pageCount - 1) else {
            throw PDFOperationError.corruptedDocument
        }
    }
    
    /// Safely merge multiple PDFs into this document
    /// - Parameter pdfs: Array of PDFDocuments to merge
    /// - Returns: The merged document (self)
    /// - Throws: PDFOperationError if merge fails
    @discardableResult
    func mergePDFs(_ pdfs: [PDFDocument]) throws -> PDFDocument {
        guard !pdfs.isEmpty else {
            return self
        }
        
        // Validate all source documents
        for (index, pdf) in pdfs.enumerated() {
            do {
                try pdf.validate()
            } catch {
                throw PDFOperationError.mergeFailure("Source PDF at index \(index) is invalid: \(error.localizedDescription)")
            }
        }
        
        // Append all pages from each document
        for pdf in pdfs {
            for pageIndex in 0..<pdf.pageCount {
                guard let page = pdf.page(at: pageIndex) else {
                    throw PDFOperationError.mergeFailure("Could not access page \(pageIndex)")
                }
                insert(page, at: pageCount)
            }
        }
        
        return self
    }
    
    /// Reorder pages within the document
    /// - Parameters:
    ///   - sourceIndex: Index of the page to move
    ///   - destinationIndex: Target index for the page
    /// - Throws: PDFOperationError if indices are invalid
    func reorderPage(from sourceIndex: Int, to destinationIndex: Int) throws {
        try validate()
        
        guard sourceIndex >= 0 && sourceIndex < pageCount else {
            throw PDFOperationError.invalidPageIndex(sourceIndex)
        }
        
        guard destinationIndex >= 0 && destinationIndex < pageCount else {
            throw PDFOperationError.invalidPageIndex(destinationIndex)
        }
        
        guard sourceIndex != destinationIndex else {
            return // No-op
        }
        
        // Extract the page
        guard let page = self.page(at: sourceIndex) else {
            throw PDFOperationError.invalidPageIndex(sourceIndex)
        }
        
        // Remove from source
        removePage(at: sourceIndex)
        
        // Insert at destination (adjust index if moving forward)
        let adjustedDestination = sourceIndex < destinationIndex ? destinationIndex - 1 : destinationIndex
        insert(page, at: adjustedDestination)
    }
    
    /// Delete pages at specified indices
    /// - Parameter indices: Set of page indices to delete
    /// - Throws: PDFOperationError if any index is invalid
    func deletePages(at indices: Set<Int>) throws {
        try validate()
        
        // Validate all indices first
        for index in indices {
            guard index >= 0 && index < pageCount else {
                throw PDFOperationError.invalidPageIndex(index)
            }
        }
        
        guard indices.count < pageCount else {
            throw PDFOperationError.emptyDocument
        }
        
        // Remove pages in reverse order to maintain valid indices
        for index in indices.sorted(by: >) {
            removePage(at: index)
        }
    }
    
    /// Delete a single page
    /// - Parameter index: Index of the page to delete
    /// - Throws: PDFOperationError if index is invalid
    func deletePage(at index: Int) throws {
        try deletePages(at: [index])
    }
    
    /// Create a new document containing only the specified pages
    /// - Parameter indices: Set of page indices to extract
    /// - Returns: New PDFDocument with extracted pages
    /// - Throws: PDFOperationError if any index is invalid
    func extractPages(at indices: Set<Int>) throws -> PDFDocument {
        try validate()
        
        let newDocument = PDFDocument()
        
        // Validate and extract pages in order
        for index in indices.sorted() {
            guard index >= 0 && index < pageCount else {
                throw PDFOperationError.invalidPageIndex(index)
            }
            
            guard let page = self.page(at: index) else {
                throw PDFOperationError.invalidPageIndex(index)
            }
            
            newDocument.insert(page, at: newDocument.pageCount)
        }
        
        return newDocument
    }
}
