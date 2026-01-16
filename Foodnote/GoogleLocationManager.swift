import Foundation
import CoreLocation
import GoogleMaps

class GoogleLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = GoogleLocationManager()
    
    private let manager = CLLocationManager()
    private let geocoder = GMSGeocoder()
    
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
    
    // Get location string from current device location using Google Geocoding
    func getLocationString() async -> String? {
        requestLocation()
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        guard let location = currentLocation else {
            return nil
        }
        
        return await reverseGeocode(location: location)
    }
    
    // Get location string from a specific CLLocation using Google Geocoding
    func getLocationString(from location: CLLocation) async -> String? {
        return await reverseGeocode(location: location)
    }
    
    // Google reverse geocoding
    private func reverseGeocode(location: CLLocation) async -> String? {
        print("🗺️ Google Geocoding for: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        return await withCheckedContinuation { continuation in
            geocoder.reverseGeocodeCoordinate(location.coordinate) { response, error in
                if let error = error {
                    print("❌ Google Geocoding error: \(error)")
                    continuation.resume(returning: nil)
                    return
                }
                
                guard let address = response?.firstResult() else {
                    print("❌ No results from Google Geocoding")
                    continuation.resume(returning: nil)
                    return
                }
                
                print("📍 Got address from Google: \(address)")
                
                var components: [String] = []
                
                // Try to get locality information
                if let subLocality = address.subLocality {
                    print("  - subLocality: \(subLocality)")
                    components.append(subLocality)
                }
                
                if let locality = address.locality {
                    print("  - locality: \(locality)")
                    components.append(locality)
                }
                
                if let country = address.country {
                    print("  - country: \(country)")
                    components.append(country)
                }
                
                // Fallback to thoroughfare or lines
                if components.isEmpty {
                    if let thoroughfare = address.thoroughfare {
                        print("  - thoroughfare: \(thoroughfare)")
                        components.append(thoroughfare)
                    } else if let lines = address.lines, !lines.isEmpty {
                        print("  - lines: \(lines[0])")
                        components.append(lines[0])
                    }
                }
                
                let locationString = components.isEmpty ? "Unknown Location" : components.joined(separator: ", ")
                print("✅ Final Google location string: \(locationString)")
                
                DispatchQueue.main.async {
                    self.locationString = locationString
                }
                
                continuation.resume(returning: locationString)
            }
        }
    }
    
    // CLLocationManagerDelegate methods
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first
        print("📍 Current location updated: \(currentLocation?.coordinate.latitude ?? 0), \(currentLocation?.coordinate.longitude ?? 0)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location manager error: \(error.localizedDescription)")
    }
}
