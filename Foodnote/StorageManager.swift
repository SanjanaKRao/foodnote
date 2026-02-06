import Foundation
import UIKit
import Photos

struct StoredImage: Identifiable {
    let id: String
    let fileURL: URL
    let createdDate: Date
}

final class StorageManager {
    static let shared = StorageManager()
    private init() {}

    enum StorageError: Error, LocalizedError {
        case documentsUnavailable
        case writeFailed
        case listFailed
        case deleteFailed
        case photoLibraryAccessDenied

        var errorDescription: String? {
            switch self {
            case .documentsUnavailable: return "Documents directory is unavailable."
            case .writeFailed: return "Failed to write the image to disk."
            case .listFailed: return "Failed to list saved images."
            case .deleteFailed: return "Failed to delete the image."
            case .photoLibraryAccessDenied: return "Photo library access denied."
            }
        }
    }

    var documentsURL: URL {  // Changed from private to public
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    @discardableResult
    func saveImage(_ image: UIImage, quality: CGFloat = 0.9, saveToPhotos: Bool = false) throws -> StoredImage {
        // Save to app documents (existing code)
        let id = UUID().uuidString
        let url = documentsURL.appendingPathComponent("\(id).jpg")
        guard let data = image.jpegData(compressionQuality: quality) else {
            throw StorageError.writeFailed
        }
        do {
            try data.write(to: url, options: .atomic)
            
            // Only save to Photos library if requested (for camera photos)
            if saveToPhotos {
                saveToPhotosLibrary(image: image)
            }
            
            return StoredImage(id: id, fileURL: url, createdDate: Date())
        } catch {
            throw StorageError.writeFailed
        }
    }
    
    // Private function to save to Photos
    private func saveToPhotosLibrary(image: UIImage) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized else { return }
            
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, error in
                if let error = error {
                    print("Error saving to Photos: \(error.localizedDescription)")
                }
            }
        }
    }

    func listImages() throws -> [StoredImage] {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.creationDateKey], options: [.skipsHiddenFiles])
            return files
                .filter { $0.pathExtension.lowercased() == "jpg" || $0.pathExtension.lowercased() == "jpeg" }
                .compactMap { url in
                    let values = try? url.resourceValues(forKeys: [.creationDateKey])
                    let created = values?.creationDate ?? Date.distantPast
                    let id = url.deletingPathExtension().lastPathComponent
                    return StoredImage(id: id, fileURL: url, createdDate: created)
                }
        } catch {
            throw StorageError.listFailed
        }
    }

    func deleteImage(_ image: StoredImage) throws {
        do {
            try FileManager.default.removeItem(at: image.fileURL)
        } catch {
            throw StorageError.deleteFailed
        }
    }
    
    func saveNote(_ note: FoodNote) throws {
        let url = documentsURL.appendingPathComponent("\(note.id).json")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(note)
            try data.write(to: url, options: .atomic)
        } catch {
            throw StorageError.writeFailed
        }
    }

    func loadNote(for imageId: String) throws -> FoodNote? {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            
            for file in files where file.pathExtension == "json" {
                let data = try Data(contentsOf: file)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let note = try decoder.decode(FoodNote.self, from: data)
                if note.imageId == imageId {
                    return note
                }
            }
            return nil
        } catch {
            return nil
        }
    }

    func deleteNote(for imageId: String) throws {
        if let note = try loadNote(for: imageId) {
            let url = documentsURL.appendingPathComponent("\(note.id).json")
            try FileManager.default.removeItem(at: url)
        }
    }
}
