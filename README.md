# 🍽️ FoodNote

An iOS app to capture, organize, and remember your food experiences. Never forget that amazing restaurant or dish again!

## 📱 Overview

FoodNote is a personal food journal that lets you photograph your meals and save detailed notes about where you ate, what you thought, and how to find it again. Built with SwiftUI and powered by Google Maps, it's the perfect companion for food lovers who want to remember their culinary adventures.

## ✨ Features

### 📸 Photo Management
- **Camera Integration** - Take photos directly in the app
- **Photo Library Upload** - Import existing food photos
- **Full Quality Storage** - Original quality photos saved to Photos app, compressed versions in app for efficiency
- **EXIF Location** - Automatically extracts location from uploaded photos

### 🤖 Smart Detection
- **AI Food Recognition** - Uses OpenAI Vision API to automatically detect food names
- **Auto Location Detection** - GPS-based location tagging for camera photos
- **EXIF Location Extraction** - Reads location data from uploaded photos

### 🗺️ Google Maps Integration
- **Restaurant Search** - Find and select restaurants with autocomplete
- **Interactive Map Picker** - Drop pins anywhere to mark locations
- **Detailed Address Data** - Stores neighborhood, city, and GPS coordinates
- **Auto-fill** - Selecting a restaurant automatically fills name and location
- **World Map View** - See all your food experiences on an interactive global map

### 📝 Rich Note System
Each food entry includes:
- **Name** - What you ate (AI-assisted or manual)
- **Restaurant** - Where you ate (searchable on map)
- **Location** - Neighborhood/city/country (auto-filled from map)
- **Coordinates** - Precise GPS location (latitude/longitude)
- **Rating** - 1-5 star rating system
- **Description** - Your thoughts and notes

### 🔍 Smart Organization

#### Sort by All
- Grid view of all photos
- Sorted by date (newest first)
- Real-time search and filtering

#### Sort by Map
- **Interactive World Map** - See all your dining experiences globally
- **Restaurant Markers** - Red fork/knife icons mark each country
- **Smart Sizing** - Marker size scales with photo count (1 photo = small, 10+ photos = large)
- **Photo Count Badge** - White badge shows number of photos per location
- **Country Grouping** - One marker per country showing all photos from that region
- **Tap to Explore** - Tap any marker to view all photos from that country
- **Accurate Positioning** - Uses real GPS coordinates from photos, fallback to country centers

#### Sort by Location
- Groups photos by Country → City → Restaurant hierarchy
- Sub-groups by restaurant with photo counts
- Horizontal scrolling cards for easy browsing
- Navigate to restaurant detail view

#### Sort by Rating
- Groups photos by star rating (5★ to 1★)
- Quickly find your favorites
- Horizontal scroll layout

#### Search & Filter
- Real-time search across location, restaurant, and food names
- Date filtering (single day or date range)
- Calendar picker for easy date selection
- Combined search + date filters

### 🖼️ Image Detail View
- Full-screen image viewing
- Pinch to zoom (1x - 5x)
- Pan when zoomed
- Double-tap to zoom in/out
- Overlay showing all note details
- Quick edit access via pencil icon
- Swipe back navigation

### 🗑️ Batch Operations
- **Multi-Select Mode** - Select multiple photos at once
- **Visual Feedback** - Selected items show blue border and checkmark
- **Batch Delete** - Delete multiple entries with one confirmation
- **Context Menu** - Long-press for individual edit/delete options

## 🛠️ Technical Stack

### Frameworks & Technologies
- **SwiftUI** - Modern declarative UI
- **Core Location** - GPS and location services
- **Google Maps SDK** - Interactive maps and place search
- **Google Places API** - Restaurant search and autocomplete
- **Google Geocoding API** - Reverse geocoding for addresses
- **OpenAI Vision API** - AI-powered food detection
- **Photos Framework** - Photo library integration
- **PhotosUI** - Image picking
- **SceneKit** - (Deprecated) Previously used for 3D globe view
- **File-based Storage** - JSON for notes, JPEG for images (no database required)

### Architecture
- **MVVM Pattern** - Separation of concerns
- **Async/Await** - Modern Swift concurrency
- **File-based Storage** - JSON for notes, JPEG for images
- **State Management** - SwiftUI @State and @Binding
- **Navigation** - NavigationLink for push navigation, sheets for modals

### Storage Strategy
- **Images**: Compressed JPEG in app documents folder (0.9 quality, ~1-2MB)
- **Photos Library**: Full quality originals with GPS metadata (camera photos only)
- **Notes**: JSON files with unique IDs linking to images
- **Coordinates**: Stored in notes for accurate map positioning
- **Typical Storage**: ~800KB per food entry (app) + 2MB (Photos for camera captures)

## 📁 Project Structure
```
Foodnote/
├── FoodnoteApp.swift              # App entry point, Google Maps initialization
├── ContentView.swift              # Main view with grid/list/map layouts
├── AddNoteView.swift              # Form for adding/editing notes
├── ImageDetailView.swift          # Full-screen image viewer with zoom
├── DatePickerView.swift           # Custom date range picker
├── RestaurantDetailView.swift     # Restaurant-specific photo grid
├── RestaurantRowPreview.swift     # Restaurant preview cards
├── CountryDetailView.swift        # Country photo grid (from map view)
├── InteractiveMapView.swift       # World map with markers
├── Models/
│   ├── FoodNote.swift            # Note data model (with coordinates)
│   ├── StoredImage.swift         # Image metadata model
│   └── CountryAnnotation.swift   # Map marker data model
├── Services/
│   ├── StorageManager.swift      # File storage management
│   ├── OpenAIService.swift       # AI food detection
│   └── GoogleLocationManager.swift # Google Maps location & geocoding
├── GoogleMaps/
│   ├── GoogleMapsLocationPickerView.swift
│   ├── GoogleMapsLocationPicker.swift
│   ├── GoogleMapsPickerViewController.swift
│   ├── GoogleMapWithMarkersView.swift         # SwiftUI wrapper for map
│   └── GoogleMapWithMarkersViewController.swift # UIKit map controller
└── ImagePicker.swift             # Camera/library picker
```

## 🚀 Setup Instructions

### Prerequisites
- Xcode 14+
- iOS 15.0+
- Google Maps API Key
- OpenAI API Key

### Installation

1. **Clone the repository**
```bash
   git clone https://github.com/yourusername/foodnote.git
   cd foodnote
```

2. **Install Google Maps SDK**
   
   The project uses Swift Package Manager:
   - Open in Xcode
   - Dependencies should auto-resolve
   
   Or manually add:
   - https://github.com/googlemaps/ios-maps-sdk
   - https://github.com/googlemaps/ios-places-sdk

3. **Add API Keys**
   
   In `FoodnoteApp.swift`:
```swift
   GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
   GMSPlacesClient.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```
   
   In `OpenAIService.swift`:
```swift
   private let apiKey = "YOUR_OPENAI_API_KEY"
```

4. **Configure Google Cloud Console**
   - Enable Maps SDK for iOS
   - Enable Places API
   - Enable Geocoding API
   - Restrict API key to your bundle ID (recommended for security)

5. **Add Info.plist Permissions**
```xml
   <key>NSCameraUsageDescription</key>
   <string>We need camera access to take photos of your food</string>
   
   <key>NSPhotoLibraryUsageDescription</key>
   <string>We need access to your photo library to save and import food photos</string>
   
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>We need your location to tag where you ate and show restaurants on the map</string>
```

6. **Build and Run**
   - Select your device or simulator
   - Press `Cmd + R`

## 💰 API Costs

### Google Maps
- **Free Tier**: $200/month credit (~28,000 map loads)
- **Personal Use**: Completely free for typical usage
- **Map View**: Free within monthly credit
- **Places API**: ~$17 per 1,000 searches (rarely exceeds free tier)
- **Geocoding**: ~$5 per 1,000 requests (included in free tier)

### OpenAI Vision API
- **Model**: gpt-4o-mini
- **Cost**: ~$0.15 per 1,000 images analyzed
- **Rate Limits**: Handled with retry logic
- **Optimization**: Images resized to 512px before sending to reduce costs

**Estimated Monthly Cost for Personal Use**: $0 (stays within free tiers)

## 🔐 Privacy & Security

- ✅ All data stored locally on device
- ✅ Photos never leave device (except when using AI detection or map search)
- ✅ Location data only used for tagging and map display
- ✅ GPS coordinates stored locally for map accuracy
- ✅ No user tracking or analytics
- ✅ No third-party data sharing
- ✅ API keys should be kept secure (use environment variables in production)

## 🎨 Design Features

- **Clean White Background** - Minimalist, food-focused design
- **Dark Text** - High contrast for accessibility
- **Smooth Animations** - Spring animations for natural feel
- **Responsive UI** - Adapts to different screen sizes
- **Gesture Support** - Pinch, zoom, pan, double-tap
- **Loading Indicators** - Clear feedback for async operations
- **Custom Map Markers** - Restaurant icons with smart sizing
- **Visual Feedback** - Selection states, hover effects, shadows

## 🐛 Known Issues & Limitations

- Map markers grouped by country (not individual restaurant locations)
- Google Maps search limited to 5 results for performance
- AI detection requires internet connection
- Rate limited to prevent API abuse (retry logic implemented)
- Map view requires top/bottom padding to avoid UI overlap

## 🔄 Future Enhancements

- [ ] Individual restaurant markers (instead of country grouping)
- [ ] Cluster markers for nearby restaurants
- [ ] Export data as CSV/JSON
- [ ] iCloud sync across devices
- [ ] Share photos with notes to social media
- [ ] Restaurant recommendations based on ratings
- [ ] Offline mode for viewing saved items
- [ ] Multiple photo support per entry
- [ ] Custom tags/categories
- [ ] Statistics and insights dashboard
- [ ] Dark mode support
- [ ] Heatmap view of favorite areas
- [ ] Route planning to visit saved restaurants

## 📄 License

This project is for personal/educational use. API keys and services are subject to their respective terms of service.

## 🙏 Acknowledgments

- **Google Maps Platform** - Maps, places, and geocoding services
- **OpenAI** - AI-powered food recognition
- **SwiftUI** - Modern iOS development framework
- **Claude AI** - Development assistance and code review

## 📧 Contact

For questions or suggestions, please open an issue on GitHub.

---

Made with ❤️ and 🍕 by [Sanjana Rao]
