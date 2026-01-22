//
//  GoogleMapViewController.swift
//  Foodnote
//
//  Created by Sanjana K Rao on 20/01/26.
//


import UIKit
import GoogleMaps
import CoreLocation

class GoogleMapViewController: UIViewController {
    
    var mapView: GMSMapView!
    var annotations: [CountryAnnotation] = []
    var onCountryTapped: ((String, [StoredImage]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create map centered on world view
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
        mapView.settings.tiltGestures = false
        mapView.settings.rotateGestures = true
        
        view.addSubview(mapView)
        
        // Add markers
        addMarkers()
    }
    
    func updateAnnotations(_ newAnnotations: [CountryAnnotation]) {
        annotations = newAnnotations
        if isViewLoaded {
            addMarkers()
        }
    }
    
    private func addMarkers() {
        // Clear existing markers
        mapView.clear()
        
        for annotation in annotations {
            let marker = GMSMarker(position: annotation.coordinate)
            
            // Create custom marker view
            let markerView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 80))
            
            // Circle with count
            let circle = UIView(frame: CGRect(x: 10, y: 0, width: 40, height: 40))
            circle.backgroundColor = .systemRed
            circle.layer.cornerRadius = 20
            circle.layer.shadowColor = UIColor.black.cgColor
            circle.layer.shadowOpacity = 0.3
            circle.layer.shadowOffset = CGSize(width: 0, height: 2)
            circle.layer.shadowRadius = 4
            
            let countLabel = UILabel(frame: circle.bounds)
            countLabel.text = "\(annotation.imageCount)"
            countLabel.textColor = .white
            countLabel.font = .systemFont(ofSize: 14, weight: .bold)
            countLabel.textAlignment = .center
            circle.addSubview(countLabel)
            
            // Country name label
            let nameLabel = UILabel(frame: CGRect(x: 0, y: 45, width: 60, height: 30))
            nameLabel.text = annotation.country
            nameLabel.textColor = .white
            nameLabel.font = .systemFont(ofSize: 11, weight: .semibold)
            nameLabel.textAlignment = .center
            nameLabel.numberOfLines = 2
            nameLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            nameLabel.layer.cornerRadius = 4
            nameLabel.clipsToBounds = true
            
            markerView.addSubview(circle)
            markerView.addSubview(nameLabel)
            
            // Convert to image
            UIGraphicsBeginImageContextWithOptions(markerView.bounds.size, false, 0)
            markerView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let markerImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            marker.iconView = UIImageView(image: markerImage)
            marker.groundAnchor = CGPoint(x: 0.5, y: 1.0)
            marker.userData = annotation
            marker.map = mapView
        }
    }
}

extension GoogleMapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let annotation = marker.userData as? CountryAnnotation {
            onCountryTapped?(annotation.country, annotation.images)
        }
        return true
    }
}