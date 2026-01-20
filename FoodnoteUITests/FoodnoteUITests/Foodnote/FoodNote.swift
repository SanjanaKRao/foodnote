import Foundation

struct FoodNote: Codable, Identifiable {
    let id: String
    var name: String
    var restaurant: String
    var location: String
    var rating: Int  // 1-5
    var description: String
    var imageId: String
    var createdDate: Date
    
    init(id: String = UUID().uuidString, name: String = "", restaurant: String = "",location: String = "", rating: Int = 3, description: String = "", imageId: String, createdDate: Date = Date()) {
        self.id = id
        self.name = name
        self.restaurant = restaurant
        self.location = location
        self.rating = rating
        self.description = description
        self.imageId = imageId
        self.createdDate = createdDate
    }
}
