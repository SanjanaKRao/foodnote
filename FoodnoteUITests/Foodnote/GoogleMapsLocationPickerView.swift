import SwiftUI
import CoreLocation

struct GoogleMapsLocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    
    let initialLocation: CLLocation?
    let onLocationSelected: (CLLocation, String, String?) -> Void  
    
    var body: some View {
        NavigationStack {
            GoogleMapsLocationPicker(
                initialLocation: initialLocation,
                onLocationSelected: { location, address, placeName in
                    onLocationSelected(location, address, placeName)
                    dismiss()
                }
            )
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("Select Restaurant/Locality")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
