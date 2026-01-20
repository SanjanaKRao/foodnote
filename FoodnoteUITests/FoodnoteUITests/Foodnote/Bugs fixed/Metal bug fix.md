**This is a Metal/graphics rendering crash related to the map view being deallocated improperly. It's a common issue with MapKit in SwiftUI sheets. Fixed it by ensuring proper cleanup:**

- showMap state - Controls whether the map is rendered
- cleanupAndDismiss() - Hides the map before dismissing to prevent Metal crash
- dismantleUIView - Properly cleans up the map view resources
- Delay before dismiss - Small delay after hiding map to ensure cleanup completes
- Animations wrapped - Used withAnimation for smoother transitions
