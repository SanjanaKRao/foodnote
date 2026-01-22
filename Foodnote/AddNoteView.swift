import SwiftUI
import CoreLocation

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var location: String
    @State private var restaurant: String
    @State private var rating: Int
    @State private var description: String
    @State private var isDetectingFood = false
    @State private var isDetectingLocation = false
    @State private var showLocationPicker = false
    @State private var selectedLocation: CLLocation?
    
    let imageId: String
    let image: UIImage?
    let photoLocation: CLLocation?
    let onSave: (FoodNote) -> Void
    
    init(imageId: String, image: UIImage? = nil, existingNote: FoodNote? = nil, photoLocation: CLLocation? = nil, onSave: @escaping (FoodNote) -> Void) {
        self.imageId = imageId
        self.image = image
        self.photoLocation = photoLocation
        self.onSave = onSave
        
        _name = State(initialValue: existingNote?.name ?? "")
        _location = State(initialValue: existingNote?.location ?? "")
        _restaurant = State(initialValue: existingNote?.restaurant ?? "")
        _rating = State(initialValue: existingNote?.rating ?? 3)
        _description = State(initialValue: existingNote?.description ?? "")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                formContent
            }
            .navigationTitle("Add Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $showLocationPicker) {
                GoogleMapsLocationPickerView(initialLocation: selectedLocation ?? photoLocation) { location, address, placeName in
                    selectedLocation = location
                    
                    // ALWAYS just update location, never touch restaurant
                    self.location = address
                    
                    // Only auto-fill restaurant if it's currently empty
                    if let place = placeName, !place.isEmpty, restaurant.isEmpty {
                        restaurant = place
                        print("✅ Auto-filled Restaurant: \(place), Location: \(address)")
                    } else {
                        print("✅ Updated Location: \(address), Restaurant unchanged: \(restaurant)")
                    }
                    
                    isDetectingLocation = false
                }
            }
            .onAppear {
                if location.isEmpty {
                    detectLocationInBackground()
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var formContent: some View {
        Form {
            foodDetailsSection
            ratingSection
            descriptionSection
        }
        .scrollContentBackground(.hidden)
    }
    
    private var foodDetailsSection: some View {
        Section("Food Details") {
            nameField
            restaurantField
            locationField
        }
        .listRowBackground(Color.white)
        .foregroundStyle(.black)
    }
    
    private var nameField: some View {
        HStack {
            TextField("", text: $name, prompt: Text("Name").foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6)))
                .foregroundStyle(Color(red: 0, green: 0, blue: 0))
                .disabled(isDetectingFood)
            
            if !name.isEmpty {
                Button {
                    name = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.black)
                }
                .buttonStyle(.plain)
            }
            
            if let _ = image, name.isEmpty {
                Button {
                    detectFoodName()
                } label: {
                    if isDetectingFood {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "wand.and.stars")
                            .foregroundStyle(.blue)
                    }
                }
                .buttonStyle(.plain)
            }
            
        }
    }
    
    private var restaurantField: some View {
        HStack{
            TextField("", text: $restaurant, prompt: Text("Restaurant").foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6)))
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color(red: 0, green: 0, blue: 0))
            if !restaurant.isEmpty {
                Button {
                    restaurant = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.black)
                }
                .buttonStyle(.plain)
            }
            
            Button {
                showLocationPicker = true
                restaurant = ""
            } label: {
                if isDetectingLocation {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "map.fill")
                        .foregroundStyle(.green)
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    private var locationField: some View {
        HStack {
            TextField("", text: $location, prompt: Text("Location").foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6)))
                .foregroundStyle(Color(red: 0, green: 0, blue: 0))
                .disabled(isDetectingLocation)
            
            if !location.isEmpty {
                Button {
                    location = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.black)
                }
                .buttonStyle(.plain)
            }
            
            Button {
                showLocationPicker = true
            } label: {
                if isDetectingLocation {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "map.fill")
                        .foregroundStyle(.green)
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    private var ratingSection: some View {
        Section("Rating") {
            HStack {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .foregroundStyle(star <= rating ? Color.yellow : Color(red: 0, green: 0, blue: 0))
                        .font(.title2)
                        .onTapGesture {
                            rating = star
                        }
                }
            }
        }
        .listRowBackground(Color.white)
        .foregroundColor(Color(red: 0, green: 0, blue: 0))
    }
    
    private var descriptionSection: some View {
        Section("Description") {
            ZStack(alignment: .topLeading) {
                if description.isEmpty {
                    Text("Start typing here...")
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                }
                
                TextEditor(text: $description)
                    .font(.system(size: 16, weight: .regular))
                    .frame(minHeight: 100)
                    .foregroundStyle(Color(red: 0, green: 0, blue: 0))
                    .opacity(description.isEmpty ? 0.5 : 1)
                
                if !description.isEmpty {
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                description = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.black)
                            }
                            .buttonStyle(.plain)
                            .padding(8)
                        }
                        Spacer()
                    }
                }
            }
        }
        .listRowBackground(Color.white)
        .foregroundColor(Color(red: 0, green: 0, blue: 0))
    }
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                dismiss()
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                let note = FoodNote(
                    name: name,
                    restaurant: restaurant,
                    location: location,
                    latitude: selectedLocation?.coordinate.latitude,  
                    longitude: selectedLocation?.coordinate.longitude,
                    rating: rating,
                    description: description,
                    imageId: imageId
                )
                onSave(note)
                dismiss()
            }
            .disabled(name.isEmpty || isDetectingFood || isDetectingLocation)
        }
    }
    
    private var locationPickerSheet: some View {
        LocationPickerView(initialLocation: selectedLocation ?? photoLocation) { location in
            selectedLocation = location
            reverseGeocodeLocation(location)
        }
    }
    
    // MARK: - Functions
    
    private func detectFoodName() {
        guard let image = image else { return }
        
        isDetectingFood = true
        
        Task {
            do {
                let detectedName = try await OpenAIService.shared.detectFoodName(from: image)
                await MainActor.run {
                    name = detectedName
                    isDetectingFood = false
                }
            } catch {
                await MainActor.run {
                    isDetectingFood = false
                    print("Failed to detect food: \(error)")
                }
            }
        }
    }
    
    private func detectLocationInBackground() {
        print("🔍 detectLocationInBackground called")
        print("📍 photoLocation exists: \(photoLocation != nil)")
        print("📍 location field is empty: \(location.isEmpty)")
        
        // First try photo location if available
        if let photoLoc = photoLocation {
            print("📍 Using photo location: \(photoLoc.coordinate.latitude), \(photoLoc.coordinate.longitude)")
            Task {
                print("🌐 Starting Google reverse geocode...")
                if let locationString = await GoogleLocationManager.shared.getLocationString(from: photoLoc) {
                    print("✅ Got location string: \(locationString)")
                    await MainActor.run {
                        if location.isEmpty {
                            location = locationString
                            selectedLocation = photoLoc
                            print("✅ Location field updated to: \(locationString)")
                        } else {
                            print("⚠️ Location field already filled, skipping")
                        }
                    }
                } else {
                    print("❌ Failed to get location string from photo location")
                }
            }
        } else {
            // Fallback to current location for camera photos
            print("📱 No photo location, using current device location")
            Task {
                print("🌐 Requesting current location from Google...")
                if let locationString = await GoogleLocationManager.shared.getLocationString() {
                    print("✅ Got location string: \(locationString)")
                    await MainActor.run {
                        if location.isEmpty {
                            location = locationString
                            print("✅ Location field updated to: \(locationString)")
                        } else {
                            print("⚠️ Location field already filled, skipping")
                        }
                    }
                } else {
                    print("❌ Failed to get current location string")
                }
            }
        }
    }
    
    private func reverseGeocodeLocation(_ clLocation: CLLocation) {
        isDetectingLocation = true
        
        Task {
            if let locationString = await AppleLocationManager.shared.getLocationString(from: clLocation) {
                await MainActor.run {
                    location = locationString
                    isDetectingLocation = false
                }
            } else {
                await MainActor.run {
                    isDetectingLocation = false
                }
            }
        }
    }
}
