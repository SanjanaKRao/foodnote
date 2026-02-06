import SwiftUI
import CoreLocation
import PhotosUI

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
    @State private var showImagePicker = false
    @State private var newImage: UIImage?
    
    let imageId: String
    @State private var displayImage: UIImage?
    let existingNote: FoodNote?
    let photoLocation: CLLocation?
    let onSave: (FoodNote, UIImage?) -> Void  // Updated callback to include optional new image
    
    init(imageId: String, image: UIImage? = nil, existingNote: FoodNote? = nil, photoLocation: CLLocation? = nil, onSave: @escaping (FoodNote, UIImage?) -> Void) {
        self.imageId = imageId
        self._displayImage = State(initialValue: image)
        self.existingNote = existingNote
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
            .navigationTitle(existingNote == nil ? "Add Note" : "Edit Note")
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
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: .photoLibrary) { result in
                    switch result {
                    case .success(let pickerResult):
                        newImage = pickerResult.image
                        displayImage = pickerResult.image
                        
                        // Optionally update location from new image
                        if let newLocation = pickerResult.location {
                            selectedLocation = newLocation
                            Task {
                                if let locationString = await GoogleLocationManager.shared.getLocationString(from: newLocation) {
                                    await MainActor.run {
                                        location = locationString
                                    }
                                }
                            }
                        }
                        
                        // Re-detect food name from new image if name is empty
                        if name.isEmpty {
                            detectFoodName()
                        }
                        
                    case .failure(let error):
                        print("❌ Image picker error: \(error)")
                    }
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
            imageSection
            foodDetailsSection
            ratingSection
            descriptionSection
        }
        .scrollContentBackground(.hidden)
    }
    
    private var imageSection: some View {
        Section {
            VStack(spacing: 12) {
                if let img = displayImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    // Placeholder if no image
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .overlay(
                            VStack {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundStyle(.gray)
                                Text("No image")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                        )
                }
                if existingNote != nil {
                    Button {
                        showImagePicker = true
                    } label: {
                        HStack {
                            Image(systemName: newImage != nil ? "arrow.triangle.2.circlepath" : "photo.badge.plus")
                            Text(newImage != nil ? "Image Updated - Tap to change again" : (existingNote != nil ? "Replace Image" : "Change Image"))
                                .font(.subheadline)
                        }
                        .foregroundStyle(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
        .listRowBackground(Color.white)
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
            
            if displayImage != nil, name.isEmpty {
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
                    id: existingNote?.id ?? imageId,
                    name: name,
                    restaurant: restaurant,
                    location: location,
                    latitude: selectedLocation?.coordinate.latitude ?? existingNote?.latitude,
                    longitude: selectedLocation?.coordinate.longitude ?? existingNote?.longitude,
                    rating: rating,
                    description: description,
                    imageId: imageId
                )
                
                print("💾 Saving note:")
                print("   Note ID: \(note.id)")
                print("   Image ID: \(note.imageId)")
                print("   Name: '\(note.name)'")
                print("   New image: \(newImage != nil)")
                
                onSave(note, newImage)
                dismiss()
            }
            .disabled(name.isEmpty || isDetectingFood || isDetectingLocation)
        }
    }
    
    // MARK: - Functions
    
    private func detectFoodName() {
        guard let image = displayImage else { return }
        
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
}
