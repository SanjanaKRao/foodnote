# 🍽️ FoodNote

A beautiful iOS app to capture, organize, and remember your food experiences. Never forget that amazing restaurant or dish again!

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
- **Detailed Address Data** - Stores neighborhood and city information
- **Auto-fill** - Selecting a restaurant automatically fills name and location

### 📝 Rich Note System
Each food entry includes:
- **Name** - What you ate (AI-assisted or manual)
- **Restaurant** - Where you ate (searchable on map)
- **Location** - Neighborhood/city (auto-filled from map)
- **Rating** - 1-5 star rating system
- **Description** - Your thoughts and notes

### 🔍 Smart Organization

#### Sort by Location
- Groups photos by location (neighborhood/city)
- Sub-groups by restaurant
- Horizontal scrolling cards for easy browsing

#### Sort by Rating
- Groups photos by star rating (5★ to 1★)
- Quickly find your favorites

#### Search & Filter
- Real-time search across location, restaurant, and food names
- Date filtering (single day or date range)
- Calendar picker for easy date selection

### 🖼️ Image Detail View
- Full-screen image viewing
- Pinch to zoom (1x - 5x)
- Pan when zoomed
- Double-tap to zoom in/out
- Overlay showing all note details
- Quick edit access

## 🛠️ Technical Stack

### Frameworks & Technologies
- **SwiftUI** - Modern declarative UI
- **Core Location** - GPS and location services
- **Google Maps SDK** - Interactive maps and place search
- **Google Places API** - Restaurant search and autocomplete
- **OpenAI Vision API** - AI-powered food detection
- **Photos Framework** - Photo library integration
- **PhotosUI** - Image picking
- **Core Data-free** - File-based storage for simplicity

### Architecture
- **MVVM Pattern** - Separation of concerns
- **Async/Await** - Modern Swift concurrency
- **File-based Storage** - JSON for notes, JPEG for images
- **State Management** - SwiftUI @State and @Binding

### Storage Strategy
- **Images**: Compressed JPEG in app documents folder (0.9 quality)
- **Photos Library**: Full quality originals with GPS metadata
- **Notes**: JSON files with unique IDs
- **Typical Storage**: ~800KB per food entry (app) + 2MB (Photos)

## 📁 Project Structure
```
Foodnote/
├── FoodnoteApp.swift              # App entry point, Google Maps initialization
├── ContentView.swift              # Main view with grid/list layouts
├── AddNoteView.swift              # Form for adding/editing notes
├── ImageDetailView.swift          # Full-screen image viewer
├── DatePickerView.swift           # Custom date range picker
├── RestaurantDetailView.swift     # Restaurant-specific photo grid
├── RestaurantRowPreview.swift     # Restaurant preview cards
├── Models/
│   ├── FoodNote.swift            # Note data model
│   └── StoredImage.swift         # Image metadata model
├── Services/
│   ├── StorageManager.swift      # File storage management
│   ├── OpenAIService.swift       # AI food detection
│   ├── LocationManager.swift     # Apple Maps location (backup)
│   └── GoogleLocationManager.swift # Google Maps location
├── GoogleMaps/
│   ├── GoogleMapsLocationPickerView.swift
│   ├── GoogleMapsLocationPicker.swift
│   └── GoogleMapsPickerViewController.swift
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
   - Restrict API key to your bundle ID

5. **Add Info.plist Permissions**
```xml
   <key>NSCameraUsageDescription</key>
   <string>We need camera access to take photos of your food</string>
   
   <key>NSPhotoLibraryUsageDescription</key>
   <string>We need access to your photo library</string>
   
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>We need your location to tag where you ate</string>
```

6. **Build and Run**
   - Select your device or simulator
   - Press `Cmd + R`

## 💰 API Costs

### Google Maps
- **Free Tier**: $200/month credit (~28,000 map loads)
- **Personal Use**: Completely free
- **Cost After Free Tier**: ~$7 per 1,000 requests

### OpenAI Vision API
- **Model**: gpt-4o-mini
- **Cost**: ~$0.15 per 1,000 images
- **Rate Limits**: Handled with retry logic
- **Optimization**: Images resized to 512px before sending

## 🔐 Privacy & Security

- ✅ All data stored locally on device
- ✅ Photos never leave device (except to Google/OpenAI APIs)
- ✅ Location data only used for tagging
- ✅ No user tracking or analytics
- ✅ API keys should be kept secure (use environment variables in production)

## 🎨 Design Features

- **Clean White Background** - Minimalist, food-focused design
- **Dark Placeholder Text** - High contrast for accessibility
- **Smooth Animations** - Spring animations for natural feel
- **Responsive UI** - Adapts to different screen sizes
- **Gesture Support** - Pinch, zoom, pan, double-tap
- **Loading Indicators** - Clear feedback for async operations

## 🐛 Known Issues & Limitations

- First image tap after app load may show black screen briefly (workaround in place)
- Google Maps search limited to 5 results for performance
- AI detection requires internet connection
- Rate limited to prevent API abuse (retry logic implemented)

## 🔄 Future Enhancements

- [ ] Export data as CSV/JSON
- [ ] iCloud sync
- [ ] Share photos with notes
- [ ] Restaurant recommendations based on ratings
- [ ] Offline mode for viewing saved items
- [ ] Multiple photo support per entry
- [ ] Custom tags/categories
- [ ] Statistics and insights
- [ ] Dark mode support

## 📄 License

This project is for personal/educational use. API keys and services are subject to their respective terms of service.

## 🙏 Acknowledgments

- **Google Maps Platform** - Maps and place data
- **OpenAI** - AI food recognition
- **SwiftUI** - Modern iOS development
- **Claude AI** - Development assistance

## 📧 Contact

For questions or suggestions, please open an issue on GitHub.

---

Made with ❤️ and 🍕 by [Sanjana Rao]
