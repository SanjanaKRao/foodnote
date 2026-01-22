# Foodnote - Functional Requirements (Brief)

## Project Overview
**Product:** Foodnote - iOS Food Journal App  
**Purpose:** Capture, organize, and remember dining experiences with photos, notes, and locations

---

## 1. Photo Management

### 1.1 Photo Capture
- **Camera**: Take photos directly, auto-save to iOS Photos (full quality) + app storage (compressed)
- **Upload**: Import from photo library, extract EXIF location data
- **Storage**: Compressed JPEG (0.7 quality, ~800KB) in app documents folder

### 1.2 Photo Display
- **Grid View**: 160x160px thumbnails with note info
- **Horizontal Scroll**: 280x280px cards for rating view
- **Full-Screen Detail**: Pinch-to-zoom (1x-5x), pan, double-tap zoom toggle

---

## 2. Note System

### 2.1 Note Fields
- **Food Name** (required) - With AI detection option
- **Restaurant** (optional) - Searchable via Google Maps
- **Location** (optional) - Auto-detected from GPS/EXIF
- **Rating** (1-5 stars, default: 3)
- **Description** (optional multi-line text)
- **Coordinates** (latitude/longitude, auto-stored)

### 2.2 Note Operations
- **Create**: Auto-opens after photo capture
- **Edit**: Tap note text, pencil icon, or context menu
- **Save**: JSON files in app documents, persists across app restarts
- **Auto-Detection**: Food name (AI), location (GPS/EXIF)

---

## 3. AI Features

### 3.1 Food Name Detection
- **Provider**: OpenAI Vision API (gpt-4o-mini)
- **Trigger**: Magic wand button when name field empty
- **Process**: Image → AI analysis → Auto-fill name field

### 3.2 Location Detection
- **EXIF Data**: Extract from uploaded photos
- **GPS**: Current location for camera photos
- **Google Geocoding**: Convert coordinates to "SubLocality, Locality, Country"

---

## 4. Google Maps Integration

### 4.1 Restaurant Picker
- **Search**: Autocomplete for restaurants/places
- **Selection**: Auto-fills restaurant name + location
- **Smart Fill**: Updates location only if restaurant already entered

### 4.2 Map View
- **Display**: World map with restaurant markers (red fork/knife icons)
- **Marker Size**: Scales with photo count (40px-120px)
- **Interaction**: Tap marker → View all photos from that country
- **Positioning**: Uses real GPS coordinates from photos

---

## 5. Organization & Views

### 5.1 Sort Options
- **All**: Grid of all photos, newest first
- **Map**: Google Maps with country markers
- **Location**: Grouped by Country → City → Restaurant
- **Rating**: Grouped by star rating (5★ → Unrated)

### 5.2 Search & Filter
- **Search**: Real-time text search (name, restaurant, location)
- **Date Filter**: Single day or date range selection
- **Combined**: Search + date filter work together

---

## 6. Batch Operations

### 6.1 Multi-Select Mode
- **Activation**: "Select" button
- **Selection**: Tap images (blue border + checkmark)
- **Visual Feedback**: Selected scaled 95%, unselected 60% opacity

### 6.2 Batch Delete
- **Trigger**: "Delete X" floating button
- **Confirmation**: Alert with count
- **Action**: Removes photos + notes from storage

---

## 7. Navigation

### 7.1 Main Interface
- **Top**: Search bar, date filter, select button
- **Middle**: Sort menu, content area (grid/map/scroll)
- **Bottom**: "Take Photo" (blue) + "Upload" (green) buttons

### 7.2 Navigation Patterns
- **NavigationLink**: Photo detail views (push with back button)
- **Sheet**: Add/edit note forms (modal)
- **Full-Screen Cover**: Country detail from map
- **Context Menu**: Long-press for Edit/Delete

---

## 8. Data Persistence

### 8.1 Storage
- **Images**: `{uuid}.jpg` in app documents folder
- **Notes**: `{note-id}.json` in app documents folder
- **In-Memory**: Dictionary mapping imageId → FoodNote

### 8.2 Data Models
```swift
FoodNote: name, restaurant, location, lat/lon, rating, description, imageId, date
StoredImage: id, fileURL, createdDate
CountryAnnotation: country, coordinate, imageCount, images[]
```

---

## 9. External Dependencies

### 9.1 APIs
- **Google Maps**: Maps display, restaurant search, geocoding
- **OpenAI Vision**: AI-powered food name detection

### 9.2 iOS Frameworks
- **SwiftUI**: UI framework
- **CoreLocation**: GPS and location services
- **Photos/PhotosUI**: Photo library access
- **UIKit**: Camera, image processing

---

## 10. Key User Workflows

### Add Entry
1. Take/upload photo → 2. Auto-detect location → 3. (Optional) AI detect food name → 4. Fill details → 5. Save

### View Entries
- Browse grid/scroll views
- Tap photo for full-screen detail with zoom
- Switch sort modes (All/Map/Location/Rating)

### Edit Entry
- Tap note text OR pencil icon OR long-press → Edit form → Save

### Delete
- **Single**: Long-press → Delete → Confirm
- **Batch**: Select mode → Tap multiple → Delete X → Confirm

### Search
- Type in search bar (real-time filter)
- Add date filter (single day or range)
- Clear with X button

---

## 11. Technical Highlights

- **Storage**: File-based (no database), JSON + JPEG
- **Image Quality**: Full quality in iOS Photos, compressed in app
- **Coordinates**: Stored with notes for accurate map positioning
- **Persistence**: All data survives app restarts
- **Rate Limiting**: Retry logic for OpenAI API
- **Free Tier**: Google Maps $200/month credit (sufficient for personal use)

---

**Version**: 1.0  
**Platform**: iOS 15.0+  
**Architecture**: SwiftUI + MVVM pattern
