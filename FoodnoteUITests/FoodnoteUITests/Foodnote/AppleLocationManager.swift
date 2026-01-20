import Foundation
import CoreLocation

class AppleLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = AppleLocationManager()
    
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var currentLocation: CLLocation?
    @Published var locationString: String = ""
    
    override private init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        let status = manager.authorizationStatus
        
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            print("Location access denied")
        @unknown default:
            break
        }
    }
    
    // Get location string from current device location
    func getLocationString() async -> String? {
        requestLocation()
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        guard let location = currentLocation else {
            return nil
        }
        
        return await reverseGeocode(location: location)
    }
    
    // Get location string from a specific CLLocation (for EXIF data)
    func getLocationString(from location: CLLocation) async -> String? {
        return await reverseGeocode(location: location)
    }
    
    // Private reverse geocoding function
    private func reverseGeocode(location: CLLocation) async -> String? {
        return await withCheckedContinuation { continuation in
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    print("Geocoding error: \(error)")
                    continuation.resume(returning: nil)
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    continuation.resume(returning: nil)
                    return
                }
                
                var components: [String] = []
                
                if let subLocality = placemark.subLocality {
                    components.append(subLocality)
                }
                
                if let locality = placemark.locality {
                    components.append(locality)
                }
                
                if components.isEmpty {
                    if let name = placemark.name {
                        components.append(name)
                    } else if let thoroughfare = placemark.thoroughfare {
                        components.append(thoroughfare)
                    }
                }
                
                let locationString = components.isEmpty ? "Unknown Location" : components.joined(separator: ", ")
                
                DispatchQueue.main.async {
                    self.locationString = locationString
                }
                
                continuation.resume(returning: locationString)
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
