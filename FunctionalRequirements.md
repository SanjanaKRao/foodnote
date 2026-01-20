# Functional Requirements

## 1. Overview
Foodnote is an app which stores all your best dishes/(dishes to avoid) at your favorite/hated restaurant at the quick snap of your camera. It auto detects the food using an LLM model, it auto detects your location. Input the name of your restaurant(optionall) and add a rating to it(1-5 stars). You can then sort it based on location/restaurant so you never have to forget your memories again.

---

## 2. Scope
Define what is **in scope** and **out of scope**.

### In Scope
- Capture food photos
- Store photos locally
- Associate notes with photos
- Upload photos
- 

### Out of Scope
- Cloud synchronization
- Social sharing
- Payment processing

---

## 3. Actors
List all user types or system actors.

| Actor | Description |
|-----|-------------|
| User | End user of the mobile application |
| System | Application backend or local services |
| OS Services | Camera, Photos, Location services |

---

## 4. Functional Requirements

### FR-1: Capture Food Photo
**Description:**  
The system shall allow the user to capture a food photo using the device camera.

**Priority:** High  
**Actors:** User  
**Preconditions:** Camera permission granted  
**Postconditions:** Photo is saved locally  

---

### FR-2: Upload Food Photo from Library
**Description:**  
The system shall allow the user to select a food photo from the device photo library.

**Priority:** High  
**Actors:** User  
**Preconditions:** Photo library permission granted  
**Postconditions:** Selected photo is stored locally  

---

### FR-3: Store Photo Metadata
**Description:**  
The system shall store metadata associated with each photo, including name, restaurant, location, rating, and description.

**Priority:** High  
**Actors:** System  

---

### FR-4: Auto-detect Location
**Description:**  
The system shall automatically determine the photo location using available metadata or device location services.

**Priority:** Medium  
**Actors:** System  
**Fallback:** Device GPS if photo metadata is unavailable  

---

### FR-5: View Photos by Date
**Description:**  
The system shall display photos sorted by creation date.

**Priority:** Medium  
**Actors:** User  

---

### FR-6: View Photos by Location
**Description:**  
The system shall group and display photos by location.

**Priority:** High  
**Actors:** User  

---

### FR-7: View Photos by Restaurant
**Description:**  
The system shall group photos by restaurant within a selected location.

**Priority:** High  
**Actors:** User  

---

### FR-8: Edit Food Note
**Description:**  
The system shall allow the user to edit food note details for a selected photo.

**Priority:** High  
**Actors:** User  

---

### FR-9: Delete Photo
**Description:**  
The system shall allow the user to delete a photo and its associated note.

**Priority:** Medium  
**Actors:** User  

---

## 5. Error Handling Requirements

### ER-1: Permission Denied
**Description:**  
If required permissions are denied, the system shall notify the user and disable the affected functionality.

---

### ER-2: Storage Failure
**Description:**  
If photo or note storage fails, the system shall display an error message.

---

## 6. Non-Functional Constraints (Reference)
(Optionally link to a separate NFR document.)

- Performance
- Security
- Usability
- Accessibility

---

## 7. Assumptions
List assumptions made while defining requirements.

- The device supports camera and photo library access
- Location services may be unavailable

---

## 8. Open Questions
Track unresolved decisions.

- Should cloud backup be supported in the future?
- Should photos be exportable?

---

## 9. Change Log

| Version | Date | Description |
|-------|------|-------------|
| 1.0 | YYYY-MM-DD | Initial draft |

