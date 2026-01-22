import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var region: MKCoordinateRegion
    @State private var selectedCoordinate: CLLocationCoordinate2D
    @State private var isGeocodingLocation = false
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    @State private var showMap = true  // Add this to control map lifecycle
    
    let onLocationSelected: (CLLocation) -> Void
    
    init(initialLocation: CLLocation? = nil, onLocationSelected: @escaping (CLLocation) -> Void) {
        self.onLocationSelected = onLocationSelected
        
        let coordinate = initialLocation?.coordinate ?? CLLocationCoordinate2D(
            latitude: 12.9716,
            longitude: 77.5946
        )
        
        _selectedCoordinate = State(initialValue: coordinate)
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Map - conditionally show to prevent crash
                if showMap {
                    MapWithCenter(region: $region, center: $selectedCoordinate)
                        .ignoresSafeArea(edges: .top)
                }
                
                // Crosshair in center for precise selection
                VStack {
                    Spacer()
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.green)
                        .shadow(radius: 3)
                    Spacer()
                }
                .allowsHitTesting(false)
                
                // UI Overlay
                VStack {
                    // Search bar
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.gray)
                            
                            TextField("", text: $searchText, prompt: Text("Search for a place").foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6)))
                                .textFieldStyle(.plain)
                                .autocorrectionDisabled()
                                .foregroundStyle(.black)
                                .onSubmit {
                                    searchPlaces()
                                }
                            
                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                    searchResults = []
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.black)
                                }
                            }
                        }
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                        
                        if isSearching {
                            ProgressView()
                                .padding(.leading, 8)
                        }
                    }
                    .padding()
                    
                    // Search results
                    if !searchResults.isEmpty {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(searchResults, id: \.self) { item in
                                    Button {
                                        selectSearchResult(item)
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(item.name ?? "Unknown")
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundStyle(.primary)
                                                
                                                if let address = item.placemark.title {
                                                    Text(address)
                                                        .font(.caption)
                                                        .foregroundStyle(.secondary)
                                                        .lineLimit(1)
                                                }
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundStyle(.gray)
                                        }
                                        .padding()
                                        .background(Color.white)
                                    }
                                    
                                    Divider()
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    HStack(spacing: 12) {
                        Button {
                            useCurrentLocation()
                        } label: {
                            Label("Current", systemImage: "location.fill")
                                .font(.subheadline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.blue)
                                .foregroundStyle(.black)
                                .cornerRadius(12)
                        }
                        
                        Button {
                            selectLocation()
                        } label: {
                            if isGeocodingLocation {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Label("Select", systemImage: "checkmark")
                                    .font(.subheadline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(.green)
                                    .foregroundStyle(.white)
                                    .cornerRadius(12)
                            }
                        }
                        .disabled(isGeocodingLocation)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                }
            }
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        cleanupAndDismiss()
                    }
                }
            }
        }
    }
    
    private func searchPlaces() {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        searchResults = []
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            isSearching = false
            
            if let error = error {
                print("Search error: \(error.localizedDescription)")
                return
            }
            
            if let response = response {
                searchResults = response.mapItems
            }
        }
    }
    
    private func selectSearchResult(_ item: MKMapItem) {
        let coordinate = item.placemark.coordinate
        selectedCoordinate = coordinate
        
        withAnimation {
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
        
        // Clear search
        searchText = ""
        searchResults = []
    }
    
    private func useCurrentLocation() {
        AppleLocationManager.shared.requestLocation()
        
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            if let currentLoc = AppleLocationManager.shared.currentLocation {
                await MainActor.run {
                    selectedCoordinate = currentLoc.coordinate
                    withAnimation {
                        region = MKCoordinateRegion(
                            center: currentLoc.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    }
                }
            }
        }
    }
    
    private func selectLocation() {
        isGeocodingLocation = true
        
        let location = CLLocation(latitude: selectedCoordinate.latitude, longitude: selectedCoordinate.longitude)
        onLocationSelected(location)
        
        // Cleanup before dismissing
        Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            await MainActor.run {
                isGeocodingLocation = false
                cleanupAndDismiss()
            }
        }
    }
    
    private func cleanupAndDismiss() {
        // Hide map first to prevent Metal crash
        showMap = false
        
        // Small delay before dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            dismiss()
        }
    }
}

// Custom Map wrapper that updates center coordinate
struct MapWithCenter: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var center: CLLocationCoordinate2D
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: false)
        mapView.showsUserLocation = true
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        let currentCenter = mapView.region.center
        let distance = abs(currentCenter.latitude - region.center.latitude) +
                      abs(currentCenter.longitude - region.center.longitude)
        
        if distance > 0.001 {
            mapView.setRegion(region, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    static func dismantleUIView(_ uiView: MKMapView, coordinator: Coordinator) {
        // Cleanup to prevent Metal crash
        uiView.delegate = nil
        uiView.removeAnnotations(uiView.annotations)
        uiView.removeOverlays(uiView.overlays)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapWithCenter
        
        init(_ parent: MapWithCenter) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            DispatchQueue.main.async {
                self.parent.region = mapView.region
                self.parent.center = mapView.region.center
            }
        }
    }
}
