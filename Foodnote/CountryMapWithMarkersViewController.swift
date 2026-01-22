//
//  GoogleMapWithMarkersViewController.swift
//  Foodnote
//
//  Created by Sanjana K Rao on 21/01/26.
//


import UIKit
import GoogleMaps
import CoreLocation

class GoogleMapWithMarkersViewController: UIViewController {
    
    var mapView: GMSMapView!
    var annotations: [CountryAnnotation] = []
    var markerToAnnotation: [GMSMarker: CountryAnnotation] = [:]
    var onCountryTapped: ((String, [StoredImage]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("🗺️ Setting up Google Maps view")
        
        // Create map with world view
        let camera = GMSCameraPosition.camera(
            withLatitude: 20,
            longitude: 10,
            zoom: 2
        )
        
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        
        // Style the map
        mapView.mapType = .normal
        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true
        mapView.settings.tiltGestures = true
        mapView.settings.rotateGestures = true
        
        view.addSubview(mapView)
        
        print("✅ Google Map created")
    }
    
    func updateAnnotations(_ newAnnotations: [CountryAnnotation]) {
        annotations = newAnnotations
        print("📍 Updating map with \(annotations.count) countries")
        addMarkers()
    }
    
    private func addMarkers() {
        // Clear existing markers
        mapView.clear()
        markerToAnnotation.removeAll()
        
        print("📌 Adding \(annotations.count) markers to map")
        
        for annotation in annotations {
            let marker = createMarker(for: annotation)
            marker.map = mapView
            markerToAnnotation[marker] = annotation
        }
    }
    
    private func createMarker(for annotation: CountryAnnotation) -> GMSMarker {
        let marker = GMSMarker(position: annotation.coordinate)
        
        // Create custom icon with restaurant symbol
        // Size based on image count
        let baseSize: CGFloat = 40
        let sizeMultiplier = 1.0 + (CGFloat(annotation.imageCount) * 0.15)
        let iconSize = baseSize * min(sizeMultiplier, 3.0) // Max 3x size
        
        let icon = createRestaurantIcon(size: iconSize, count: annotation.imageCount)
        marker.iconView = icon
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.title = annotation.country
        marker.snippet = "\(annotation.imageCount) photo\(annotation.imageCount == 1 ? "" : "s")"
        
        print("📍 Created marker for \(annotation.country) with \(annotation.imageCount) images, size: \(iconSize)")
        
        return marker
    }
    
    private func createRestaurantIcon(size: CGFloat, count: Int) -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        
        // Red circle background
        let circle = UIView(frame: container.bounds)
        circle.backgroundColor = .systemRed
        circle.layer.cornerRadius = size / 2
        circle.layer.shadowColor = UIColor.black.cgColor
        circle.layer.shadowOpacity = 0.3
        circle.layer.shadowOffset = CGSize(width: 0, height: 2)
        circle.layer.shadowRadius = 4
        container.addSubview(circle)
        
        // Restaurant fork/knife icon using SF Symbol
        let config = UIImage.SymbolConfiguration(pointSize: size * 0.5, weight: .medium)
        let restaurantImage = UIImage(systemName: "fork.knife", withConfiguration: config)
        let imageView = UIImageView(image: restaurantImage)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(
            x: size * 0.25,
            y: size * 0.25,
            width: size * 0.5,
            height: size * 0.5
        )
        container.addSubview(imageView)
        
        // Count badge in bottom-right
        if count > 1 {
            let badgeSize: CGFloat = size * 0.4
            let badge = UIView(frame: CGRect(
                x: size - badgeSize,
                y: size - badgeSize,
                width: badgeSize,
                height: badgeSize
            ))
            badge.backgroundColor = .white
            badge.layer.cornerRadius = badgeSize / 2
            badge.layer.borderWidth = 2
            badge.layer.borderColor = UIColor.systemRed.cgColor
            
            let countLabel = UILabel(frame: badge.bounds)
            countLabel.text = "\(count)"
            countLabel.textColor = .systemRed
            countLabel.font = .systemFont(ofSize: badgeSize * 0.6, weight: .bold)
            countLabel.textAlignment = .center
            badge.addSubview(countLabel)
            
            container.addSubview(badge)
        }
        
        return container
    }
}

extension GoogleMapWithMarkersViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let annotation = markerToAnnotation[marker] {
            print("🎯 Tapped marker for: \(annotation.country)")
            onCountryTapped?(annotation.country, annotation.images)
            return true
        }
        return false
    }
}