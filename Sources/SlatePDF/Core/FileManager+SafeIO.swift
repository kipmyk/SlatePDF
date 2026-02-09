import Foundation
import PDFKit
import CryptoKit

/// Extension providing safe file I/O operations for PDF documents
extension FileManager {
    
    enum SafeIOError: LocalizedError {
        case backupFailed(String)
        case saveFailed(String)
        case checksumMismatch
        case rollbackFailed(String)
        case invalidPath
        
        var errorDescription: String? {
            switch self {
            case .backupFailed(let reason):
                return "Backup failed: \(reason)"
            case .saveFailed(let reason):
                return "Save failed: \(reason)"
            case .checksumMismatch:
                return "Checksum validation failed - data may be corrupted"
            case .rollbackFailed(let reason):
                return "Rollback failed: \(reason)"
            case .invalidPath:
                return "Invalid file path"
            }
        }
    }
    
    /// Safely save a PDF document with atomic write and backup
    /// - Parameters:
    ///   - document: PDFDocument to save
    ///   - url: Destination URL
    ///   - createBackup: Whether to create a backup of existing file
    /// - Throws: SafeIOError if save fails
    func safelySavePDF(_ document: PDFDocument, to url: URL, createBackup: Bool = true) throws {
        // Ensure the document is valid
        guard document.pageCount > 0 else {
            throw SafeIOError.saveFailed("Document has no pages")
        }
        
        let originalFileExists = self.fileExists(atPath: url.path)
        var backupURL: URL?
        
        // Create backup if file exists
        if originalFileExists && createBackup {
            backupURL = url.appendingPathExtension("backup")
            do {
                if self.fileExists(atPath: backupURL!.path) {
                    try removeItem(at: backupURL!)
                }
                try copyItem(at: url, to: backupURL!)
            } catch {
                throw SafeIOError.backupFailed(error.localizedDescription)
            }
        }
        
        // Write to temporary file first
        let tempURL = url.deletingLastPathComponent()
            .appendingPathComponent(".\(url.lastPathComponent).tmp")
        
        do {
            // Write to temp file
            guard document.write(to: tempURL) else {
                throw SafeIOError.saveFailed("PDFDocument write failed")
            }
            
            // Verify the temp file can be read back
            guard let verifyDoc = PDFDocument(url: tempURL),
                  verifyDoc.pageCount == document.pageCount else {
                throw SafeIOError.checksumMismatch
            }
            
            // Move temp file to final destination atomically
            if originalFileExists {
                try removeItem(at: url)
            }
            try moveItem(at: tempURL, to: url)
            
            // Success - remove backup
            if let backupURL = backupURL, self.fileExists(atPath: backupURL.path) {
                try? removeItem(at: backupURL)
            }
            
        } catch {
            // Rollback - restore from backup if available
            if let backupURL = backupURL, self.fileExists(atPath: backupURL.path) {
                do {
                    if self.fileExists(atPath: url.path) {
                        try removeItem(at: url)
                    }
                    try moveItem(at: backupURL, to: url)
                } catch {
                    throw SafeIOError.rollbackFailed(error.localizedDescription)
                }
            }
            
            // Clean up temp file
            if self.fileExists(atPath: tempURL.path) {
                try? removeItem(at: tempURL)
            }
            
            throw SafeIOError.saveFailed(error.localizedDescription)
        }
    }
    
    /// Calculate SHA256 checksum of a file
    /// - Parameter url: File URL
    /// - Returns: Hex string of checksum
    func calculateChecksum(for url: URL) throws -> String {
        let data = try Data(contentsOf: url)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    /// Verify file integrity by comparing checksums
    /// - Parameters:
    ///   - url: File to verify
    ///   - expectedChecksum: Expected SHA256 checksum
    /// - Returns: true if checksums match
    func verifyFileIntegrity(at url: URL, expectedChecksum: String) throws -> Bool {
        let actualChecksum = try calculateChecksum(for: url)
        return actualChecksum == expectedChecksum
    }
}
