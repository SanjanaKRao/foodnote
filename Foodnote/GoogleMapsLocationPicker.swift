import SwiftUI
import CoreLocation

struct GoogleMapsLocationPicker: UIViewControllerRepresentable {
    let initialLocation: CLLocation?
    let onLocationSelected: (CLLocation, String, String?) -> Void  
    
    func makeUIViewController(context: Context) -> GoogleMapsPickerViewController {
        let viewController = GoogleMapsPickerViewController()
        viewController.onLocationSelected = onLocationSelected
        viewController.initialLocation = initialLocation
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: GoogleMapsPickerViewController, context: Context) {}
}
