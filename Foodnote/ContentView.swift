import SwiftUI
import CoreLocation

enum SortOption {
    case all
    case location
    case map
    case rating
}

// MARK: - Keyboard Dismissal Extension
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView: View {
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    @State private var showAddNote = false
    @State private var selectedImage: StoredImage?
    @State private var pendingUIImage: UIImage?
    @State private var pendingLocation: CLLocation?
    @State private var images: [StoredImage] = []
    @State private var notes: [String: FoodNote] = [:]
    @State private var errorMessage: String?
    @State private var sortOption: SortOption = .all
    @State private var searchText = ""
    @State private var showDatePicker = false
    @State private var selectedStartDate: Date?
    @State private var selectedEndDate: Date?
    @State private var isSelectingDateRange = false
    @State private var showImageDetail = false
    @State private var detailImage: UIImage?
    @State private var isSelectionMode = false
    @State private var selectedImages: Set<String> = []
    
    
    // Computed property for date filter status
    var hasDateFilter: Bool {
        selectedStartDate != nil || selectedEndDate != nil
    }
    
    // Filtered images based on search and date
    var filteredImages: [StoredImage] {
        var result = images
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { img in
                guard let note = notes[img.id] else { return false }
                
                let searchLower = searchText.lowercased()
                let matchesLocation = note.location.lowercased().contains(searchLower)
                let matchesRestaurant = note.restaurant.lowercased().contains(searchLower)
                let matchesName = note.name.lowercased().contains(searchLower)
                
                return matchesLocation || matchesRestaurant || matchesName
            }
        }
        
        // Filter by date
        if let startDate = selectedStartDate {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: startDate)
            
            if let endDate = selectedEndDate {
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: endDate) ?? endDate
                result = result.filter { img in
                    img.createdDate >= startOfDay && img.createdDate < endOfDay
                }
            } else {
                // Single day
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startDate) ?? startDate
                result = result.filter { img in
                    img.createdDate >= startOfDay && img.createdDate < endOfDay
                }
            }
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar and date picker
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            // Search bar
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(.gray)
                                
                                TextField("", text: $searchText, prompt: Text("Search by name or place").foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6)))
                                    .textFieldStyle(.plain)
                                    .foregroundStyle(.black)
                                    .autocorrectionDisabled()
                                
                                if !searchText.isEmpty {
                                    Button {
                                        searchText = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.black)
                                    }
                                }
                            }
                            .padding(12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            
                            // Date picker button
                            Button {
                                showDatePicker = true
                            } label: {
                                Image(systemName: hasDateFilter ? "calendar.badge.clock" : "calendar")
                                    .font(.title3)
                                    .foregroundStyle(hasDateFilter ? .blue : .gray)
                                    .frame(width: 44, height: 44)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Active date filter display and select button row
                        if hasDateFilter  {
                            HStack {
                                dateFilterBadge
                                clearFilterButton
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        
                    }
                    
                    if filteredImages.isEmpty {
                        Spacer()
                        ContentUnavailableView(
                            searchText.isEmpty && !hasDateFilter ? "No food photos yet" : "No results found",
                            systemImage: searchText.isEmpty && !hasDateFilter ? "photo.on.rectangle.angled" : "magnifyingglass",
                            description: Text(searchText.isEmpty && !hasDateFilter ? "Tap the buttons below to add your first photo." : "Try adjusting your search or date filter")
                        )
                        .padding()
                        Spacer()
                    } else {
                        // Sort toggle
                        HStack {
                            Spacer()
                            
                            // Select button
                            if !images.isEmpty {
                                selectButton
                            }
                            Menu {
                                Button {
                                    withAnimation {
                                        sortOption = .all
                                    }
                                } label: {
                                    HStack {
                                        Text("All")
                                        if sortOption == .all {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                                
                                Button {
                                    withAnimation {
                                        sortOption = .location
                                    }
                                } label: {
                                    HStack {
                                        Text("Location")
                                        if sortOption == .location {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                                
                                Button {
                                        withAnimation {
                                            sortOption = .map
                                        }
                                    } label: {
                                        HStack {
                                            Text("Map")
                                            if sortOption == .map {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                
                                Button {
                                    withAnimation {
                                        sortOption = .rating
                                    }
                                } label: {
                                    HStack {
                                        Text("Rating")
                                        if sortOption == .rating {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    //Menu label icon and text
                                    Image(systemName: sortOption == .all ? "photo.stack" : (sortOption == .map ? "map.fill" : (sortOption == .rating ? "star.fill" : "location.fill")))

                                    Text(sortOption == .all ? "All" : (sortOption == .map ? "Map" : (sortOption == .rating ? "Rating" : "Location")))
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .foregroundStyle(.blue)
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        ZStack(alignment: .bottom) {
                            if sortOption == .map {
                                    // Map view takes full space, no ScrollView
                                    InteractiveMapView(
                                        images: filteredImages,
                                        notes: notes,
                                        selectedImage: $selectedImage,
                                        pendingUIImage: $pendingUIImage,
                                        showAddNote: $showAddNote,
                                        errorMessage: $errorMessage,
                                        deleteImage: deleteImage,
                                        foodCard: { img in AnyView(foodCard(for: img)) }
                                    )
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .edgesIgnoringSafeArea(.all)
                            } else {
                                ScrollView {
                                    VStack(spacing: 20) {
                                        switch sortOption {
                                        case .all:
                                            allItemsView
                                        case .location:
                                            locationGroupedView
                                        case .rating:
                                            ratingBasedView
                                        default:
                                            EmptyView()
                                        }
                                    }
                                    .padding(.bottom, 80) // Space for camera buttons
                                }
                            }
                            // Floating delete button
                            if isSelectionMode && !selectedImages.isEmpty {
                                Button {
                                    showDeleteConfirmation()
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "trash.fill")
                                        Text("Delete \(selectedImages.count)")
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 14)
                                    .background(Color.red)
                                    .cornerRadius(25)
                                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                }
                                .padding(.bottom, 100) // Above camera buttons
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                        .animation(.spring(), value: isSelectionMode)
                        .animation(.spring(), value: selectedImages.count)
                    }
                    
                    // Camera buttons at bottom
                    HStack(spacing: 12) {
                        Button {
                            showCamera = true
                        } label: {
                            Label("Take Photo", systemImage: "camera.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.blue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        Button {
                            showPhotoLibrary = true
                        } label: {
                            Label("Upload", systemImage: "photo.on.rectangle")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.green)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding([.horizontal, .bottom])
                    .background(Color.white)
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            // All your sheets here...
            .sheet(isPresented: $showCamera) {
                print("🎥 Camera sheet dismissed")
            } content: {
                ImagePicker(sourceType: .camera) { result in
                    print("📸 Camera result received")
                    showCamera = false
                    handleImagePickerResult(result, isFromCamera: true)
                }
            }
            
            .sheet(isPresented: $showPhotoLibrary) {
                print("📚 Photo library sheet dismissed")
            } content: {
                ImagePicker(sourceType: .photoLibrary) { result in
                    print("🖼️ Photo library result received")
                    showPhotoLibrary = false
                    handleImagePickerResult(result, isFromCamera: false)
                }
            }
            
            .sheet(isPresented: $showAddNote) {
                print("📝 Add note sheet dismissed")
                pendingLocation = nil
            } content: {
                if let img = selectedImage {
                    let _ = print("📝 Add note sheet PRESENTING")
                    let _ = print("✅ Selected image ID: \(img.id)")
                    
                    AddNoteView(
                        imageId: img.id,
                        image: pendingUIImage,
                        existingNote: notes[img.id],
                        photoLocation: pendingLocation
                    ) { note in
                        print("💾 Saving note")
                        do {
                            try StorageManager.shared.saveNote(note)
                            notes[img.id] = note
                            print("✅ Note saved")
                        } catch {
                            print("❌ Failed to save: \(error)")
                            errorMessage = error.localizedDescription
                        }
                    }
                } else {
                    let _ = print("❌ ERROR: selectedImage is nil!")
                    Text("Error: No image selected")
                        .foregroundColor(.red)
                }
            }
            
            .sheet(isPresented: $showDatePicker) {
                DatePickerView(
                    selectedStartDate: $selectedStartDate,
                    selectedEndDate: $selectedEndDate,
                    isSelectingRange: $isSelectingDateRange
                )
            }
            
            .sheet(isPresented: $showImageDetail) {
                if let img = selectedImage, let uiImage = detailImage {
                    let _ = print("📸 Showing image detail view")
                    ImageDetailView(
                        image: uiImage,
                        note: notes[img.id]
                    ) {
                        showImageDetail = false
                        showAddNote = true
                    }
                }
            }
            .task {
                await loadImages()
            }
            .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
            .onChange(of: showAddNote) {
                print("🔄 showAddNote changed to: \(showAddNote)")
            }
        }
    }
    
    // MARK: - Views
    
    var allItemsView: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 20) {
            ForEach(filteredImages) { img in
                foodCard(for: img)
            }
        }
        .padding()
    }
    
    var locationGroupedView: some View {
        let groupedByLocation: [String: [StoredImage]] = Dictionary(grouping: filteredImages) { img in
            if let note = notes[img.id], !note.location.isEmpty {
                return note.location
            }
            return "No Location"
        }
        
        let sortedLocations = groupedByLocation.keys.sorted { a, b in
            if a == "No Location" { return false }
            if b == "No Location" { return true }
            return a < b
        }
        
        return LazyVStack(spacing: 24) {
            ForEach(sortedLocations, id: \.self) { location in
                let locationImages = groupedByLocation[location] ?? []
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: location == "No Location" ? "questionmark.circle" : "mappin.circle.fill")
                            .foregroundStyle(location == "No Location" ? .gray : .red)
                        
                        Text(location)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(red: 0, green: 0, blue: 0))
                        
                        Spacer()
                        
                        Text("\(locationImages.count)")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    let groupedByRestaurant: [String: [StoredImage]] = Dictionary(grouping: locationImages) { img in
                        if let note = notes[img.id], !note.restaurant.isEmpty {
                            return note.restaurant
                        }
                        return "No Restaurant"
                    }
                    
                    let sortedRestaurants = groupedByRestaurant.keys.sorted { a, b in
                        if a == "No Restaurant" { return false }
                        if b == "No Restaurant" { return true }
                        return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(sortedRestaurants, id: \.self) { restaurant in
                            let restaurantImages = (groupedByRestaurant[restaurant] ?? [])
                                .sorted { $0.createdDate > $1.createdDate }
                            
                            NavigationLink {
                                RestaurantDetailView(
                                    location: location,
                                    restaurant: restaurant,
                                    images: restaurantImages,
                                    notes: $notes,
                                    selectedImage: $selectedImage,
                                    pendingUIImage: $pendingUIImage,
                                    showAddNote: $showAddNote,
                                    errorMessage: $errorMessage,
                                    deleteImage: deleteImage(_:),
                                    foodCard: foodCard(for:)
                                )
                            } label: {
                                RestaurantRowPreview(
                                    restaurant: restaurant,
                                    images: restaurantImages,
                                    notes: notes,
                                    stackedFoodCard: stackedFoodCard(for:)
                                )
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .padding(.vertical)
    }
        
    var ratingBasedView: some View {
        let groupedByRating: [Int: [StoredImage]] = Dictionary(grouping: filteredImages) { img in
            if let note = notes[img.id] {
                return note.rating
            }
            return 0
        }
        
        let sortedRatings = groupedByRating.keys.sorted(by: >)
        
        return LazyVStack(spacing: 24) {
            ForEach(sortedRatings, id: \.self) { rating in
                let ratingImages = groupedByRating[rating] ?? []
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .font(.title3)
                                    .foregroundStyle(star <= rating ? .yellow : .gray)
                            }
                        }
                        
                        if rating == 0 {
                            Text("Unrated")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.gray)
                        }
                        
                        Spacer()
                        
                        Text("\(ratingImages.count)")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(ratingImages.sorted { $0.createdDate > $1.createdDate }) { img in
                                stackedFoodCard(for: img)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .padding(.vertical)
    }
    
    func foodCard(for img: StoredImage) -> some View {
        Group {
            if let uiImage = UIImage(contentsOfFile: img.fileURL.path) {
                VStack(alignment: .leading, spacing: 0) {  // Changed spacing to 0
                    // Image with conditional navigation
                    ZStack(alignment: .topTrailing) {
                        if isSelectionMode {
                            // In selection mode: just the image, no navigation
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 160, height: 160)
                                .clipped()
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedImages.contains(img.id) ? Color.blue : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    toggleSelection(for: img.id)
                                }
                        } else {
                            // Normal mode: navigation link
                            NavigationLink {
                                ImageDetailView(
                                    image: uiImage,
                                    note: notes[img.id]
                                ) {
                                    selectedImage = img
                                    pendingUIImage = uiImage
                                    showAddNote = true
                                }
                            } label: {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 160, height: 160)
                                    .clipped()
                                    .cornerRadius(16)
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        // Selection checkmark overlay
                        if isSelectionMode {
                            Image(systemName: selectedImages.contains(img.id) ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .foregroundStyle(selectedImages.contains(img.id) ? .blue : .white)
                                .background(
                                    Circle()
                                        .fill(selectedImages.contains(img.id) ? Color.white : Color.black.opacity(0.3))
                                        .frame(width: 24, height: 24)
                                )
                                .padding(8)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                        }
                    }
                    
                    // Note info with larger tappable area
                    VStack(spacing: 0) {
                        noteInfoView(for: img)
                            .frame(width: 160, alignment: .leading)
                            .padding(.horizontal, 8)  // Increased horizontal padding
                            .padding(.vertical, 12)   // Added vertical padding for bigger tap area
                    }
                    .frame(width: 160)
                    .background(Color.white)
                    .contentShape(Rectangle())  // Make entire area tappable
                    .onTapGesture {
                        if !isSelectionMode {
                            print("🖱️ Note area tapped for image: \(img.id)")
                            selectedImage = img
                            pendingUIImage = uiImage
                            pendingLocation = nil
                            showAddNote = true
                        }
                    }
                }
                .background(Color.white)
                .opacity(isSelectionMode && !selectedImages.contains(img.id) ? 0.6 : 1.0)
                .scaleEffect(selectedImages.contains(img.id) ? 0.95 : 1.0)
                .animation(.spring(response: 0.3), value: selectedImages.contains(img.id))
                .contextMenu {
                    if !isSelectionMode {
                        Button {
                            selectedImage = img
                            pendingUIImage = uiImage
                            pendingLocation = nil
                            showAddNote = true
                        } label: {
                            Label("Edit Note", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            deleteImage(img)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
    
    
    func stackedFoodCard(for img: StoredImage) -> some View {
        Group {
            if let uiImage = UIImage(contentsOfFile: img.fileURL.path) {
                VStack(alignment: .leading, spacing: 0) {  // Changed spacing to 0
                    // Image with conditional navigation
                    ZStack(alignment: .topTrailing) {
                        if isSelectionMode {
                            // In selection mode: just the image, no navigation
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 280, height: 280)
                                .clipped()
                                .cornerRadius(20)
                                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(selectedImages.contains(img.id) ? Color.blue : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    toggleSelection(for: img.id)
                                }
                        } else {
                            // Normal mode: navigation link
                            NavigationLink {
                                ImageDetailView(
                                    image: uiImage,
                                    note: notes[img.id]
                                ) {
                                    selectedImage = img
                                    pendingUIImage = uiImage
                                    showAddNote = true
                                }
                            } label: {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 280, height: 280)
                                    .clipped()
                                    .cornerRadius(20)
                                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        // Selection checkmark overlay
                        if isSelectionMode {
                            Image(systemName: selectedImages.contains(img.id) ? "checkmark.circle.fill" : "circle")
                                .font(.title)
                                .foregroundStyle(selectedImages.contains(img.id) ? .blue : .white)
                                .background(
                                    Circle()
                                        .fill(selectedImages.contains(img.id) ? Color.white : Color.black.opacity(0.3))
                                        .frame(width: 30, height: 30)
                                )
                                .padding(12)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                        }
                    }
                    
                    // Note info with larger tappable area
                    VStack(spacing: 0) {
                        noteInfoView(for: img, isStacked: true)
                            .frame(width: 280, alignment: .leading)
                            .padding(.horizontal, 12)  // Increased horizontal padding
                            .padding(.vertical, 16)    // Added vertical padding for bigger tap area
                    }
                    .frame(width: 280)
                    .background(Color.white)
                    .contentShape(Rectangle())  // Make entire area tappable
                    .onTapGesture {
                        if !isSelectionMode {
                            print("🖱️ Stacked note area tapped for image: \(img.id)")
                            selectedImage = img
                            pendingUIImage = uiImage
                            pendingLocation = nil
                            showAddNote = true
                        }
                    }
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                .opacity(isSelectionMode && !selectedImages.contains(img.id) ? 0.6 : 1.0)
                .scaleEffect(selectedImages.contains(img.id) ? 0.95 : 1.0)
                .animation(.spring(response: 0.3), value: selectedImages.contains(img.id))
                .contextMenu {
                    if !isSelectionMode {
                        Button {
                            selectedImage = img
                            pendingUIImage = uiImage
                            pendingLocation = nil
                            showAddNote = true
                        } label: {
                            Label("Edit Note", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            deleteImage(img)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
    
    
    func noteInfoView(for img: StoredImage, isStacked: Bool = false) -> some View {
        let fontSize: CGFloat = isStacked ? 18 : 16
        let smallFontSize: CGFloat = isStacked ? 14 : 12
        let starSize: CGFloat = isStacked ? 12 : 10
        
        return VStack(alignment: .leading, spacing: isStacked ? 6 : 4) {
            if let note = notes[img.id] {
                Text(note.name)
                    .font(.system(size: fontSize, weight: .semibold))
                    .lineLimit(1)
                    .foregroundStyle(Color(red: 0, green: 0, blue: 0))
                
                // Restaurant name
                if !note.restaurant.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: smallFontSize - 2))
                            .foregroundStyle(Color(red: 0, green: 0, blue: 0))
                        Text(note.restaurant)
                            .font(.system(size: smallFontSize))
                            .foregroundStyle(Color(red: 0, green: 0, blue: 0))
                            .lineLimit(1)
                    }
                }
                
                //Location
                if !note.location.isEmpty && !isStacked {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: smallFontSize - 2))
                            .foregroundStyle(Color(red: 0, green: 0, blue: 0))
                        Text(note.location)
                            .font(.system(size: smallFontSize))
                            .foregroundStyle(Color(red: 0, green: 0, blue: 0))
                            .lineLimit(1)
                    }
                }
                
                //Rating
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= note.rating ? "star.fill" : "star")
                            .font(.system(size: starSize))
                            .foregroundStyle(star <= note.rating ? Color.yellow : Color(red: 0, green: 0, blue: 0))
                    }
                }
                
                //Description
                if !note.description.isEmpty {
                    Text(note.description)
                        .font(.system(size: smallFontSize))
                        .foregroundStyle(Color(red: 0, green: 0, blue: 0))
                        .lineLimit(isStacked ? 3 : 2)
                        .padding(.top, 2)
                }
            } else {
                Text("Tap to add note")
                    .font(.system(size: smallFontSize))
                    .foregroundStyle(.gray.opacity(0.7))
                    .italic()
            }
        }
    }
    
    // MARK: - Helper Functions
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    func clearDateFilter() {
        selectedStartDate = nil
        selectedEndDate = nil
    }
    
    private func handleImagePickerResult(_ result: Result<ImagePickerResult, Error>, isFromCamera: Bool = false) {
        print("📥 handleImagePickerResult called")
        
        switch result {
        case .success(let pickerResult):
            print("✅ Image picker success")
            do {
                print("💾 Saving image...")
                let saved = try StorageManager.shared.saveImage(pickerResult.image, saveToPhotos: isFromCamera)
                print("✅ Saved with ID: \(saved.id)")
                
                images.insert(saved, at: 0)
                selectedImage = saved
                pendingUIImage = pickerResult.image
                pendingLocation = pickerResult.location
                
                print("✨ Opening add note...")
                showAddNote = true
                
            } catch {
                print("❌ Error: \(error)")
                errorMessage = error.localizedDescription
            }
        case .failure(let error):
            print("❌ Picker failed: \(error)")
            if (error as? ImagePickerError) != .canceled {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func loadImages() async {
        print("📂 Loading images...")
        do {
            images = try StorageManager.shared.listImages().sorted { $0.createdDate > $1.createdDate }
            print("✅ Loaded \(images.count) images")
            
            for img in images {
                if let note = try StorageManager.shared.loadNote(for: img.id) {
                    notes[img.id] = note
                }
            }
            print("✅ Loaded \(notes.count) notes")
        } catch {
            print("❌ Error loading: \(error)")
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteImage(_ img: StoredImage) {
        print("🗑️ Deleting: \(img.id)")
        do {
            try StorageManager.shared.deleteImage(img)
            try? StorageManager.shared.deleteNote(for: img.id)
            images.removeAll { $0.id == img.id }
            notes.removeValue(forKey: img.id)
            print("✅ Deleted")
        } catch {
            print("❌ Delete error: \(error)")
            errorMessage = error.localizedDescription
        }
    }
    // MARK: - Multi-Select Functions
    
    private func toggleSelection(for imageId: String) {
        if selectedImages.contains(imageId) {
            selectedImages.remove(imageId)
        } else {
            selectedImages.insert(imageId)
        }
    }
    
    private func showDeleteConfirmation() {
        let alert = UIAlertController(
            title: "Delete \(selectedImages.count) Photo\(selectedImages.count > 1 ? "s" : "")?",
            message: "This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            deleteSelectedImages()
        })
        
        // Present alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
    
    private func deleteSelectedImages() {
        // Delete all selected images
        for imageId in selectedImages {
            if let img = images.first(where: { $0.id == imageId }) {
                deleteImage(img)
            }
        }
        
        // Exit selection mode
        withAnimation {
            selectedImages.removeAll()
            isSelectionMode = false
        }
    }
    
    // MARK: - UI Components
    
    private var dateFilterBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "calendar")
                .font(.caption)
            
            Group {
                if let start = selectedStartDate, let end = selectedEndDate, start != end {
                    Text("\(formatDate(start)) - \(formatDate(end))")
                } else if let date = selectedStartDate {
                    Text(formatDate(date))
                }
            }
            .font(.caption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .foregroundStyle(.blue)
        .cornerRadius(8)
    }
    
    private var clearFilterButton: some View {
        Button {
            clearDateFilter()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.caption)
                .foregroundStyle(.gray)
        }
    }
    
    private var selectButton: some View {
        Button {
            withAnimation {
                isSelectionMode.toggle()
                if !isSelectionMode {
                    selectedImages.removeAll()
                }
            }
        } label: {
            Text(isSelectionMode ? "Cancel" : "Select")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(isSelectionMode ? .red : .blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelectionMode ? Color.red.opacity(0.3) : Color.blue.opacity(0.3), lineWidth: 1)
                )
        }
    }
}
