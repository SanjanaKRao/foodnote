import Foundation
import CoreLocation

struct FoodNote: Codable {
    let id: String
    let name: String
    let restaurant: String
    let location: String
    let latitude: Double?
    let longitude: Double?
    let rating: Int
    let description: String
    let imageId: String
    let createdDate: Date
    
    init(id: String = UUID().uuidString,
         name: String,
         restaurant: String,
         location: String,
         latitude: Double? = nil,
         longitude: Double? = nil,
         rating: Int,
         description: String,
         imageId: String,
         createdDate: Date = Date()) {
        self.id = id
        self.name = name
        self.restaurant = restaurant
        self.location = location
        self.latitude = latitude
        self.longitude = longitude 
        self.rating = rating
        self.description = description
        self.imageId = imageId
        self.createdDate = createdDate
    }
}
