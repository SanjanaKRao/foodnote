//
//  GoogleMapWithMarkersView.swift
//  Foodnote
//
//  Created by Sanjana K Rao on 21/01/26.
//


import SwiftUI

struct GoogleMapWithMarkersView: UIViewControllerRepresentable {
    let annotations: [CountryAnnotation]
    let onCountryTapped: (String, [StoredImage]) -> Void
    
    func makeUIViewController(context: Context) -> GoogleMapWithMarkersViewController {
        print("🏗️ Creating GoogleMapWithMarkersViewController")
        let viewController = GoogleMapWithMarkersViewController()
        viewController.onCountryTapped = onCountryTapped
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: GoogleMapWithMarkersViewController, context: Context) {
        print("🔄 Updating map with \(annotations.count) annotations")
        uiViewController.updateAnnotations(annotations)
    }
}