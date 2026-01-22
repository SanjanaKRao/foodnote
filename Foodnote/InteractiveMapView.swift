import SwiftUI
import CoreLocation

struct InteractiveMapView: View {
    let images: [StoredImage]
    let notes: [String: FoodNote]
    @Binding var selectedImage: StoredImage?
    @Binding var pendingUIImage: UIImage?
    @Binding var showAddNote: Bool
    @Binding var errorMessage: String?
    let deleteImage: (StoredImage) -> Void
    let foodCard: (StoredImage) -> AnyView
    
    @State private var selectedCountryData: CountryData?
    
    // Group images by country and get coordinates
    var countryAnnotations: [CountryAnnotation] {
        let groupedByCountry = Dictionary(grouping: images) { img -> String in
            if let note = notes[img.id], !note.location.isEmpty {
                let components = note.location.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                if let country = components.last {
                    return String(country)
                }
            }
            return "Unknown"
        }
        
        return groupedByCountry.compactMap { country, imgs -> CountryAnnotation? in
            guard country != "Unknown" else { return nil }
            
            // Try to get real coordinates from notes
            for img in imgs {
                if let note = notes[img.id],
                   let lat = note.latitude,
                   let lon = note.longitude {
                    print("📍 Using real coordinates for \(country): \(lat), \(lon)")
                    return CountryAnnotation(
                        country: country,
                        coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                        imageCount: imgs.count,
                        images: imgs.sorted { $0.createdDate > $1.createdDate }
                    )
                }
            }
            
            // Fallback to approximate if no real coordinates found
            print("⚠️ No real coordinates for \(country), using approximate")
            let coord = getApproximateCountryCoordinate(country)
            
            return CountryAnnotation(
                country: country,
                coordinate: coord,
                imageCount: imgs.count,
                images: imgs.sorted { $0.createdDate > $1.createdDate }
            )
        }
    }
    var body: some View {
        ZStack {
            // Google Map with padding
            GoogleMapWithMarkersView(annotations: countryAnnotations) { country, imgs in
                print("🎉 Map marker tapped: \(country) with \(imgs.count) images")
                
                // Set data for fullScreenCover
                selectedCountryData = CountryData(country: country, images: imgs)
                print("✅ Set selectedCountryData: \(selectedCountryData != nil)")
            }
            .padding(.top, 60)
            .padding(.bottom, 90)
            .edgesIgnoringSafeArea(.all)
        }
        .fullScreenCover(item: $selectedCountryData) { data in
            CountryDetailView(
                country: data.country,
                images: data.images,
                notes: notes,
                selectedImage: $selectedImage,
                pendingUIImage: $pendingUIImage,
                showAddNote: $showAddNote,
                errorMessage: $errorMessage,
                deleteImage: deleteImage,
                foodCard: foodCard
            )
        }
        .onAppear {
            print("🗺️ InteractiveMapView appeared")
            print("📊 Annotations: \(countryAnnotations.count)")
        }
    }
    
    // Helper function to get approximate country coordinates (fallback)
    private func getApproximateCountryCoordinate(_ country: String) -> CLLocationCoordinate2D {
        let countryCoordinates: [String: CLLocationCoordinate2D] = [
            "India": CLLocationCoordinate2D(latitude: 20.5937, longitude: 78.9629),
            "United States": CLLocationCoordinate2D(latitude: 37.0902, longitude: -95.7129),
            "United Kingdom": CLLocationCoordinate2D(latitude: 55.3781, longitude: -3.4360),
            "France": CLLocationCoordinate2D(latitude: 46.2276, longitude: 2.2137),
            "Germany": CLLocationCoordinate2D(latitude: 51.1657, longitude: 10.4515),
            "Italy": CLLocationCoordinate2D(latitude: 41.8719, longitude: 12.5674),
            "Spain": CLLocationCoordinate2D(latitude: 40.4637, longitude: -3.7492),
            "Japan": CLLocationCoordinate2D(latitude: 36.2048, longitude: 138.2529),
            "China": CLLocationCoordinate2D(latitude: 35.8617, longitude: 104.1954),
            "Australia": CLLocationCoordinate2D(latitude: -25.2744, longitude: 133.7751),
            "Canada": CLLocationCoordinate2D(latitude: 56.1304, longitude: -106.3468),
            "Brazil": CLLocationCoordinate2D(latitude: -14.2350, longitude: -51.9253),
            "Mexico": CLLocationCoordinate2D(latitude: 23.6345, longitude: -102.5528),
            "Singapore": CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198),
            "Thailand": CLLocationCoordinate2D(latitude: 15.8700, longitude: 100.9925),
            "UAE": CLLocationCoordinate2D(latitude: 23.4241, longitude: 53.8478),
            "Philippines": CLLocationCoordinate2D(latitude: 12.8797, longitude: 121.7740),
        ]
        
        return countryCoordinates[country] ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
}

// Helper struct for fullScreenCover(item:)
struct CountryData: Identifiable {
    let id = UUID()
    let country: String
    let images: [StoredImage]
}
