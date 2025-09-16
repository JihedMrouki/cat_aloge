
# 🐱 Cat Gallery App – Development Tasks & User Stories

This document breaks down the development tasks and user stories for the Cat Gallery App based on **flows** and **screens**.

---

## 1️⃣ Onboarding & Permissions

### Screens:
- Welcome Screen
- Permission Request Screen
- Permission Denied Screen

### Tasks:
- [ ] Setup onboarding flow with navigation
- [ ] Implement storage/photo permission handling using `permission_handler`
- [ ] Create a fallback screen if permission is denied (with retry button)
- [ ] Add state management for onboarding status (first launch vs. returning user)

### User Stories:
- As a **user**, I want to be guided to grant permissions so that the app can access my photos.
- As a **developer**, I want permission handling to be modular so it can be reused.

---

## 2️⃣ Gallery & Cat Detection

### Screens:
- My Cats (Gallery Grid)
- Cat Detection Overlay (Loading State)

### Tasks:
- [ ] Integrate `photo_manager` to fetch local photos
- [ ] Build ML detection pipeline using `tflite_flutter`
- [ ] Filter and display only cat photos in a grid layout
- [ ] Implement shimmer loading placeholders
- [ ] Add pull-to-refresh functionality to rescan gallery
- [ ] Show error widget if gallery fails to load

### User Stories:
- As a **user**, I want the app to only show cat photos so I don’t have to scroll through unrelated images.
- As a **user**, I want to refresh the gallery so I can see newly added cat photos.

---

## 3️⃣ Cat Detail & Sharing

### Screens:
- Cat Detail Screen
- Share Dialog

### Tasks:
- [ ] Create detailed cat view screen
- [ ] Display image metadata (date, size, path)
- [ ] Implement sharing functionality with `share_plus`
- [ ] Animate transitions from grid to detail view

### User Stories:
- As a **user**, I want to tap a cat photo to see more details.
- As a **user**, I want to share cat photos with my friends.

---

## 4️⃣ Favorites System

### Screens:
- Favorites Screen
- Empty Favorites Widget

### Tasks:
- [ ] Implement Hive-based favorites storage
- [ ] Create Favorites screen with grid layout
- [ ] Add/remove favorite functionality
- [ ] Sync favorites when gallery refreshes

### User Stories:
- As a **user**, I want to save my favorite cat photos and view them later.
- As a **user**, I want to remove cats from favorites if I change my mind.

---

## 5️⃣ Error & Loading States

### Screens:
- Loading Widget
- Error Widget

### Tasks:
- [ ] Create reusable LoadingWidget
- [ ] Create reusable ErrorWidget
- [ ] Display loading widget during ML detection
- [ ] Display error widget with retry option on failure

### User Stories:
- As a **user**, I want to see a loading animation when photos are being scanned.
- As a **user**, I want a clear error message if something goes wrong.

---

## 6️⃣ Testing & Polish

### Tasks:
- [ ] Write unit tests for repositories and use cases
- [ ] Write widget tests for gallery & favorites screens
- [ ] Optimize memory usage for image loading
- [ ] Add accessibility labels and improve animations
- [ ] Prepare release build and app store assets

### User Stories:
- As a **developer**, I want automated tests to ensure my code works correctly.
- As a **user**, I want the app to feel smooth and reliable.
