import SwiftUI

struct RestaurantDetailView: View {
    let location: String
    let restaurant: String
    let images: [StoredImage]

    @Binding var notes: [String: FoodNote]
    @Binding var selectedImage: StoredImage?
    @Binding var pendingUIImage: UIImage?
    @Binding var showAddNote: Bool
    @Binding var errorMessage: String?

    let deleteImage: (StoredImage) -> Void
    let foodCard: (StoredImage) -> AnyView

    init(
        location: String,
        restaurant: String,
        images: [StoredImage],
        notes: Binding<[String: FoodNote]>,
        selectedImage: Binding<StoredImage?>,
        pendingUIImage: Binding<UIImage?>,
        showAddNote: Binding<Bool>,
        errorMessage: Binding<String?>,
        deleteImage: @escaping (StoredImage) -> Void,
        foodCard: @escaping (StoredImage) -> some View
    ) {
        self.location = location
        self.restaurant = restaurant
        self.images = images
        self._notes = notes
        self._selectedImage = selectedImage
        self._pendingUIImage = pendingUIImage
        self._showAddNote = showAddNote
        self._errorMessage = errorMessage
        self.deleteImage = deleteImage
        self.foodCard = { AnyView(foodCard($0)) }
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()  // Add white background
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 20) {
                    ForEach(images) { img in
                        foodCard(img)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(restaurant == "No Restaurant" ? "Unknown Restaurant" : restaurant)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.white, for: .navigationBar)  // Make toolbar background white
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(restaurant == "No Restaurant" ? "Unknown Restaurant" : restaurant)
                        .font(.headline)
                        .foregroundStyle(Color(red: 0, green: 0, blue: 0))  // Black text
                    Text(location == "No Location" ? "Unknown Location" : location)
                        .font(.caption)
                        .foregroundStyle(Color(red: 0, green: 0, blue: 0)) 
                }
            }
        }
    }
}
