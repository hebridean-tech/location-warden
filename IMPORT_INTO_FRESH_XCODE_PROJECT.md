# Fix for the broken `.xcodeproj`

The generated Xcode project file is malformed. Do **not** use the existing `Aperture.xcodeproj`.

## Do this instead

1. Open **Xcode**
2. **File → New → Project…**
3. Choose **iOS → App**
4. Set:
   - **Product Name:** `Aperture`
   - **Interface:** `SwiftUI`
   - **Language:** `Swift`
   - **Use Core Data:** off
   - **Include Tests:** optional/off
5. Save it anywhere on your Mac

## Then replace/add these files from the generated app folder

Copy these files from the OpenClaw-generated source bundle into the new Xcode project:

- `Aperture/ApertureApp.swift`
- `Aperture/Models/Zone.swift`
- `Aperture/Services/API.swift`
- `Aperture/Services/LocationManager.swift`
- `Aperture/Views/ContentView.swift`
- `Aperture/Views/AddZoneView.swift`

Source folder in workspace:
- `projects/location-warden/ios-app/Aperture/`

## In Xcode

When dragging files in:
- check **Copy items if needed**
- check the **Aperture** app target

## Delete/replace in the fresh project

- Replace the default `ContentView.swift`
- Replace the default `ApertureApp.swift`
- Add `Models` / `Services` / `Views` groups if you want organization

## Required project settings

### Signing
- Select the app target
- **Signing & Capabilities**
- Choose your Apple team

### Background location
Add capability:
- **Background Modes** → enable **Location updates**

### Privacy strings
In target **Info** add:
- `Privacy - Location When In Use Usage Description`
- `Privacy - Location Always and When In Use Usage Description`

Suggested value for both:
- `Location Warden uses your location to trigger workout and schedule automations.`

## API target
The code is already configured to use:
- `https://arch.projectveritos.com`

## Test
Open in Safari on the phone:
- `https://arch.projectveritos.com/health`

Expected:
```json
{"status":"ok"}
```
