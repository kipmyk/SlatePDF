import PDFKit
import AppKit

/// Extension providing PDF annotation capabilities
extension PDFDocument {
    
    /// Add a text annotation at the specified location on a page
    /// - Parameters:
    ///   - text: Text content
    ///   - page: Page index
    ///   - point: Location on the page (in PDF coordinates)
    ///   - fontSize: Font size (default: 12)
    ///   - color: Text color (default: black)
    /// - Throws: PDFOperationError if page index is invalid
    func addTextAnnotation(
        text: String,
        onPage pageIndex: Int,
        at point: CGPoint,
        fontSize: CGFloat = 12,
        color: NSColor = .black
    ) throws {
        guard let page = self.page(at: pageIndex) else {
            throw PDFOperationError.invalidPageIndex(pageIndex)
        }
        
        // Create text annotation (free text)
        let bounds = CGRect(x: point.x, y: point.y, width: 200, height: 50)
        let annotation = PDFAnnotation(
            bounds: bounds,
            forType: .freeText,
            withProperties: nil
        )
        
        annotation.contents = text
        annotation.color = .clear
        annotation.font = NSFont.systemFont(ofSize: fontSize)
        annotation.fontColor = color
        
        page.addAnnotation(annotation)
    }
    
    /// Add an image stamp annotation to a page
    /// - Parameters:
    ///   - image: NSImage to add
    ///   - page: Page index
    ///   - rect: Rectangle defining image position and size
    /// - Throws: PDFOperationError if page index is invalid
    func addImageAnnotation(
        image: NSImage,
        onPage pageIndex: Int,
        at rect: CGRect
    ) throws {
        guard let page = self.page(at: pageIndex) else {
            throw PDFOperationError.invalidPageIndex(pageIndex)
        }
        
        // Create stamp annotation with image
        let annotation = PDFAnnotation(bounds: rect, forType: .stamp, withProperties: nil)
        
        // Convert image to PDF representation
        if let tiffData = image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            
            // Create appearance stream for the annotation
            let imageRep = NSImage(data: pngData)
            annotation.setValue(imageRep, forKey: "image")
        }
        
        page.addAnnotation(annotation)
    }
    
    /// Remove an annotation from a page
    /// - Parameters:
    ///   - annotation: The annotation to remove
    ///   - pageIndex: Page index
    /// - Throws: PDFOperationError if page index is invalid
    func removeAnnotation(_ annotation: PDFAnnotation, fromPage pageIndex: Int) throws {
        guard let page = self.page(at: pageIndex) else {
            throw PDFOperationError.invalidPageIndex(pageIndex)
        }
        
        page.removeAnnotation(annotation)
    }
    
    /// Get all annotations on a specific page
    /// - Parameter pageIndex: Page index
    /// - Returns: Array of annotations
    /// - Throws: PDFOperationError if page index is invalid
    func getAnnotations(onPage pageIndex: Int) throws -> [PDFAnnotation] {
        guard let page = self.page(at: pageIndex) else {
            throw PDFOperationError.invalidPageIndex(pageIndex)
        }
        
        return page.annotations
    }
}
