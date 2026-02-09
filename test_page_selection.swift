import Foundation
import PDFKit

// Quick test to verify page selection logic
let testPDFPath = "/Users/mac/Documents/images/tes.pdf"
let url = URL(fileURLWithPath: testPDFPath)

if let doc = PDFDocument(url: url) {
    print("✅ PDF loaded successfully")
    print("📄 Total pages: \(doc.pageCount)")
    
    // Test accessing different pages
    for i in 0..<min(5, doc.pageCount) {
        if let page = doc.page(at: i) {
            let bounds = page.bounds(for: .mediaBox)
            print("✅ Page \(i + 1): \(bounds.width) x \(bounds.height) pts")
        } else {
            print("❌ Failed to load page \(i + 1)")
        }
    }
    
    // Test the editor logic
    print("\n🧪 Testing editor page selection logic:")
    var selectedPageIndices = Set<Int>([2]) // Simulating page 3 selected
    
    if let firstIndex = selectedPageIndices.first {
        print("✅ Selected page index: \(firstIndex) (Page \(firstIndex + 1))")
        if let page = doc.page(at: firstIndex) {
            print("✅ Can access selected page")
        }
    } else {
        print("⚠️  No page selected, defaulting to page 0")
    }
} else {
    print("❌ Failed to load PDF from: \(testPDFPath)")
}
