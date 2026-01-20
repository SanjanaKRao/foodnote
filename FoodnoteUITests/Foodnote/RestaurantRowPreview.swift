import SwiftUI


struct RestaurantRowPreview: View {
    let restaurant: String
    let images: [StoredImage]
    let notes: [String: FoodNote]
    let stackedFoodCard: (StoredImage) -> AnyView

    init(
        restaurant: String,
        images: [StoredImage],
        notes: [String: FoodNote],
        stackedFoodCard: @escaping (StoredImage) -> some View
    ) {
        self.restaurant = restaurant
        self.images = images
        self.notes = notes
        self.stackedFoodCard = { AnyView(stackedFoodCard($0)) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(restaurant)
                    .font(.headline)
                    .foregroundStyle(Color(red: 0, green: 0, blue: 0))

                Spacer()

                Text("\(images.count)")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(images) { img in
                        stackedFoodCard(img)
                            .frame(width: 180, height:280) 
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}
