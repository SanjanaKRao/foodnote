import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class GoogleMapsPickerViewController: UIViewController {
    var mapView: GMSMapView!
    var searchBar: UISearchBar!
    var onLocationSelected: ((CLLocation, String, String?) -> Void)?  // Added placeName
    var initialLocation: CLLocation?
    var selectedMarker: GMSMarker?
    var placesClient: GMSPlacesClient!
    var searchResultsTable: UITableView!
    var searchResults: [GMSAutocompletePrediction] = []
    var selectedPlaceName: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placesClient = GMSPlacesClient.shared()
        
        // Setup map
        let camera: GMSCameraPosition
        if let initial = initialLocation {
            camera = GMSCameraPosition.camera(
                withLatitude: initial.coordinate.latitude,
                longitude: initial.coordinate.longitude,
                zoom: 15.0
            )
        } else {
            // Default to Bangalore
            camera = GMSCameraPosition.camera(
                withLatitude: 12.9716,
                longitude: 77.5946,
                zoom: 12.0
            )
        }
        
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.delegate = self
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        
        // Setup search bar
        searchBar = UISearchBar()
        let textField = searchBar.searchTextField

        if let searchIcon = textField.leftView as? UIImageView {
            searchIcon.image = searchIcon.image?.withRenderingMode(.alwaysTemplate)
            searchIcon.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        }

        searchBar.delegate = self
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search for a place",
            attributes: [
                .foregroundColor: UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            ]
        )
        searchBar.searchTextField.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .white
        searchBar.layer.cornerRadius = 10
        view.addSubview(searchBar)
        
        // Setup search results table
        searchResultsTable = UITableView()
        searchResultsTable.delegate = self
        searchResultsTable.dataSource = self
        // Don't register - will use subtitle style
        searchResultsTable.translatesAutoresizingMaskIntoConstraints = false
        searchResultsTable.isHidden = true
        searchResultsTable.layer.cornerRadius = 10
        searchResultsTable.backgroundColor = .white
        view.addSubview(searchResultsTable)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            
            searchResultsTable.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            searchResultsTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchResultsTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchResultsTable.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        // Add select button
        let selectButton = UIButton(type: .system)
        selectButton.setTitle("Select Location", for: .normal)
        selectButton.backgroundColor = .systemGreen
        selectButton.setTitleColor(.white, for: .normal)
        selectButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        selectButton.layer.cornerRadius = 12
        selectButton.translatesAutoresizingMaskIntoConstraints = false
        selectButton.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
        view.addSubview(selectButton)
        
        NSLayoutConstraint.activate([
            selectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            selectButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            selectButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            selectButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Add initial marker if location exists
        if let initial = initialLocation {
            addMarker(at: initial.coordinate)
        }
    }
    
    private func addMarker(at coordinate: CLLocationCoordinate2D) {
        selectedMarker?.map = nil
        selectedMarker = GMSMarker(position: coordinate)
        selectedMarker?.icon = GMSMarker.markerImage(with: .red)
        selectedMarker?.map = mapView
    }
    
    @objc private func selectButtonTapped() {
        guard let marker = selectedMarker else {
            print("⚠️ No marker selected")
            return
        }
        
        let location = CLLocation(
            latitude: marker.position.latitude,
            longitude: marker.position.longitude
        )
        
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(marker.position) { response, error in
            var addressString = "Unknown Location"
            
            
            if let address = response?.firstResult() {
                var components: [String] = []
                if let subLocality = address.subLocality {
                    components.append(subLocality)
                }
                if let locality = address.locality {
                    components.append(locality)
                }
                
                if let country = address.country {
                    components.append(country)
                }
                
                if !components.isEmpty {
                    addressString = components.joined(separator: ", ")
                } else if let lines = address.lines, !lines.isEmpty {
                    addressString = lines[0]
                }
            }
            
            print("📍 Selected - Place: \(self.selectedPlaceName ?? "None"), Location: \(addressString)")
            self.onLocationSelected?(location, addressString, self.selectedPlaceName)
        }
    }
}

// MARK: - GMSMapViewDelegate
extension GoogleMapsPickerViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        addMarker(at: coordinate)
        selectedPlaceName = nil  // Clear place name when manually dropping pin
        searchResultsTable.isHidden = true
        searchBar.resignFirstResponder()
    }
}

// MARK: - UISearchBarDelegate
extension GoogleMapsPickerViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            searchResults = []
            searchResultsTable.isHidden = true
            return
        }
        
        let filter = GMSAutocompleteFilter()
        filter.types = ["establishment", "geocode"]
        
        placesClient.findAutocompletePredictions(
            fromQuery: searchText,
            filter: filter,
            sessionToken: nil
        ) { results, error in
            if let error = error {
                print("❌ Autocomplete error: \(error.localizedDescription)")
                return
            }
            
            self.searchResults = results ?? []
            self.searchResultsTable.isHidden = self.searchResults.isEmpty
            self.searchResultsTable.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableViewDelegate & DataSource
extension GoogleMapsPickerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(searchResults.count, 5)  // Show max 5 results
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Use subtitle style to show full address
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        
        let prediction = searchResults[indexPath.row]
        
        // Primary text (restaurant/place name)
        cell?.textLabel?.text = prediction.attributedPrimaryText.string
        cell?.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cell?.textLabel?.numberOfLines = 1
        
        // Secondary text (full address)
        cell?.detailTextLabel?.text = prediction.attributedSecondaryText?.string
        cell?.detailTextLabel?.font = .systemFont(ofSize: 13)
        cell?.detailTextLabel?.textColor = .gray
        cell?.detailTextLabel?.numberOfLines = 2  // Allow 2 lines for long addresses
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65  // Taller rows to accommodate 2 lines
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let prediction = searchResults[indexPath.row]
        
        // Store the selected place name
        selectedPlaceName = prediction.attributedPrimaryText.string
        
        placesClient.fetchPlace(
            fromPlaceID: prediction.placeID,
            placeFields: [.coordinate, .formattedAddress, .name],  // Added .name
            sessionToken: nil
        ) { place, error in
            if let error = error {
                print("❌ Place details error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                // Use the place name if available
                if let placeName = place.name {
                    self.selectedPlaceName = placeName
                }
                
                let coordinate = place.coordinate
                self.mapView.animate(toLocation: coordinate)
                self.mapView.animate(toZoom: 15)
                self.addMarker(at: coordinate)
                self.searchResultsTable.isHidden = true
                self.searchBar.text = self.selectedPlaceName
                self.searchBar.resignFirstResponder()
            }
        }
    }
}
