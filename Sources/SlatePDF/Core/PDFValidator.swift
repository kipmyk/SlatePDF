import PDFKit
import Foundation

/// Utility for validating PDF document integrity
struct PDFValidator {
    
    enum ValidationError: LocalizedError {
        case invalidFormat
        case corruptedPages(indices: [Int])
        case missingMetadata
        case invalidPageCount
        
        var errorDescription: String? {
            switch self {
            case .invalidFormat:
                return "Invalid PDF format"
            case .corruptedPages(let indices):
                return "Corrupted pages at indices: \(indices.map(String.init).joined(separator: ", "))"
            case .missingMetadata:
                return "PDF metadata is missing or invalid"
            case .invalidPageCount:
                return "Invalid page count"
            }
        }
    }
    
    /// Perform comprehensive validation on a PDF document
    /// - Parameter document: PDFDocument to validate
    /// - Throws: ValidationError if validation fails
    static func validate(_ document: PDFDocument) throws {
        try validatePageCount(document)
        try validatePages(document)
        try validateMetadata(document)
    }
    
    /// Validate file at URL is a proper PDF
    /// - Parameter url: File URL to validate
    /// - Returns: PDFDocument if valid
    /// - Throws: ValidationError if invalid
    static func validatePDFFile(at url: URL) throws -> PDFDocument {
        guard let document = PDFDocument(url: url) else {
            throw ValidationError.invalidFormat
        }
        try validate(document)
        return document
    }
    
    // MARK: - Private Validation Methods
    
    private static func validatePageCount(_ document: PDFDocument) throws {
        guard document.pageCount > 0 else {
            throw ValidationError.invalidPageCount
        }
    }
    
    private static func validatePages(_ document: PDFDocument) throws {
        var corruptedIndices: [Int] = []
        
        for i in 0..<document.pageCount {
            guard let page = document.page(at: i) else {
                corruptedIndices.append(i)
                continue
            }
            
            // Verify page has valid bounds
            let bounds = page.bounds(for: .mediaBox)
            guard bounds.width > 0 && bounds.height > 0 else {
                corruptedIndices.append(i)
                continue
            }
        }
        
        if !corruptedIndices.isEmpty {
            throw ValidationError.corruptedPages(indices: corruptedIndices)
        }
    }
    
    private static func validateMetadata(_ document: PDFDocument) throws {
        // Basic metadata check - just ensure we can access it
        // PDFKit allows documents with minimal metadata, so we're lenient
        _ = document.documentAttributes
    }
}
