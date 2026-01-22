

import Foundation
import CoreLocation

struct CountryAnnotation: Identifiable {
    let id = UUID()
    let country: String
    let coordinate: CLLocationCoordinate2D
    let imageCount: Int
    let images: [StoredImage]
}
