# Uchiha Ultralock — iOS

Port of the Android Uchiha Ultralock app to iOS using SwiftUI.

## Features
- Authenticated login via Plexus Auth API
- 3-tab dashboard (Tối Ưu / MOD / Thông Tin)
- In-app overlay bubble menu
- FPS monitor with CADisplayLink
- Uchiha red-black theme with visual effects
- System hardware information
- Keychain-secured credential storage

## Requirements
- Xcode 16.0+
- iOS 16.0+
- Swift 5.9+

## Setup

### 1. Clone
```bash
git clone https://github.com/your-username/ultralock-ios.git
cd ultralock-ios
```

### 2. Generate Xcode project (XcodeGen)
```bash
brew install xcodegen
xcodegen generate
open Ultralock.xcodeproj
```

### 3. Build & Run
Select an iOS 16+ simulator and run (⌘R).

### 4. Asset Images
Place your images in:
- `Ultralock/Assets.xcassets/itachi_avt.imageset/itachi_avt.png`

## Project Structure
```
Ultralock/
├── Models/           # Data models
├── Services/         # Auth, Keychain, Preferences, Hardware, FPS
├── Views/            # Login, Dashboard, System Info, Profile
├── Components/       # Reusable UI components
├── Effects/          # Canvas-based visual effects
├── Overlays/         # Bubble menu overlay
├── Theme/            # Color palette and font modifiers
└── UltralockApp.swift  # App entry point
```

## Build for CI
```bash
xcodegen generate
xcodebuild build -project Ultralock.xcodeproj -scheme Ultralock -sdk iphonesimulator CODE_SIGNING_ALLOWED=NO
```

## License
Private — All rights reserved.
