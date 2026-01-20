import SwiftUI
import UIKit
import Photos
import CoreLocation

enum ImagePickerError: Error, LocalizedError, Equatable {
    case canceled
    case unavailable
    case unknown

    var errorDescription: String? {
        switch self {
        case .canceled: return "Canceled"
        case .unavailable: return "Camera is not available on this device."
        case .unknown: return "Unknown error while capturing image."
        }
    }
}

struct ImagePickerResult {
    let image: UIImage
    let location: CLLocation?
}

struct ImagePicker: UIViewControllerRepresentable {
    enum Source {
        case camera
        case photoLibrary

        var uiType: UIImagePickerController.SourceType {
            switch self {
            case .camera: return .camera
            case .photoLibrary: return .photoLibrary
            }
        }
    }

    var sourceType: Source = .camera
    var completion: (Result<ImagePickerResult, Error>) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion, sourceType: sourceType)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        guard UIImagePickerController.isSourceTypeAvailable(sourceType.uiType) else {
            DispatchQueue.main.async {
                completion(.failure(ImagePickerError.unavailable))
            }
            return picker
        }
        picker.sourceType = sourceType.uiType
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        
        if sourceType == .camera {
            picker.cameraCaptureMode = .photo
        }
        
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let completion: (Result<ImagePickerResult, Error>) -> Void
        let sourceType: Source
        
        init(completion: @escaping (Result<ImagePickerResult, Error>) -> Void, sourceType: Source) {
            self.completion = completion
            self.sourceType = sourceType
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            completion(.failure(ImagePickerError.canceled))
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            guard let image = info[.originalImage] as? UIImage else {
                completion(.failure(ImagePickerError.unknown))
                return
            }
            
            print("=== Photo Picker Debug ===")
            print("Available keys: \(info.keys)")
            
            // For photo library, get location from PHAsset
            if sourceType == .photoLibrary {
                if let asset = info[.phAsset] as? PHAsset {
                    print("Got PHAsset")
                    print("Asset has location: \(asset.location != nil)")
                    if let location = asset.location {
                        print("Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                        print("Horizontal accuracy: \(location.horizontalAccuracy)m")
                        print("Timestamp: \(location.timestamp)")
                    } else {
                        print("PHAsset location is nil")
                    }
                    
                    // Also check creation date and other metadata
                    print("Creation date: \(String(describing: asset.creationDate))")
                    print("Media type: \(asset.mediaType.rawValue)")
                    print("Source type: \(asset.sourceType.rawValue)")
                    
                    let result = ImagePickerResult(image: image, location: asset.location)
                    completion(.success(result))
                    return
                } else {
                    print("No PHAsset found in info dictionary")
                }
                
                // Check if imageURL is available
                if let imageURL = info[.imageURL] as? URL {
                    print("Got imageURL: \(imageURL)")
                } else {
                    print("No imageURL available")
                }
            }
            
            print("=== End Debug ===")
            
            // For camera or no PHAsset
            let result = ImagePickerResult(image: image, location: nil)
            completion(.success(result))
        }
    }
}
