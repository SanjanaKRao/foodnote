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
            GMSServices.provideAPIKey("")
            GMSPlacesClient.provideAPIKey("")
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
