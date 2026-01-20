//
//  FoodnoteApp.swift
//  Foodnote
//
//  Created by Sanjana K Rao on 01/09/25.
//

import SwiftUI
import GoogleMaps
import GooglePlaces

@main
struct FoodnoteApp: App {
    
    init() {
            GMSServices.provideAPIKey(Secrets.googleMapsAPIKey)
            GMSPlacesClient.provideAPIKey(Secrets.googleMapsAPIKey)
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
