# Handoff for GLaDOS: finish the Location Warden iOS app on macOS

## Goal
Create a working iOS app project in Xcode for **Location Warden**, using the already-written Swift source files in this workspace, and get it buildable/runnable on Zoe's iPhone.

## Current state
The backend is already live on Failsafe and reachable publicly.

### Backend
- Base URL: `https://arch.projectveritos.com`
- Health check: `https://arch.projectveritos.com/health`
- Expected response: `{"status":"ok"}`

### Important note
A previously generated `.xcodeproj` in this workspace is malformed. **Do not try to salvage it.**
Create a fresh Xcode iOS app project and import the source files.

## Source files to use
Use the Swift files here:

- `projects/location-warden/ios-app/LocationWarden/LocationWardenApp.swift`
- `projects/location-warden/ios-app/LocationWarden/Models/Zone.swift`
- `projects/location-warden/ios-app/LocationWarden/Services/API.swift`
- `projects/location-warden/ios-app/LocationWarden/Services/LocationManager.swift`
- `projects/location-warden/ios-app/LocationWarden/Views/ContentView.swift`
- `projects/location-warden/ios-app/LocationWarden/Views/AddZoneView.swift`

There is also a human instruction doc at:
- `projects/location-warden/ios-app/IMPORT_INTO_FRESH_XCODE_PROJECT.md`

## Desired app behavior
- SwiftUI app named `LocationWarden`
- Connects to `https://arch.projectveritos.com`
- Fetches auth token from `/token`
- Lists zones from `/location/zones`
- Lets user add/delete zones
- Monitors geofences in background
- Sends enter/exit events to `/location/event`

## What GLaDOS should do
1. Create a fresh **iOS App** Xcode project named `LocationWarden`
2. Import the above Swift files into the project
3. Fix compile issues and project structure issues
4. Ensure required frameworks/capabilities are present:
   - SwiftUI
   - CoreLocation
   - MapKit
   - Background Modes → Location updates
5. Add privacy strings to the app target:
   - `Privacy - Location When In Use Usage Description`
   - `Privacy - Location Always and When In Use Usage Description`
   Suggested value:
   - `Location Warden uses your location to trigger workout and schedule automations.`
6. Set signing/team so Zoe can build to device
7. Test build in Xcode
8. If needed, adjust code to satisfy current Xcode / iOS SDK requirements
9. Leave the finished Xcode project somewhere obvious on the Mac and tell Zoe where it is

## Known code caveats GLaDOS may need to fix
The Swift files were generated remotely and may need cleanup. Likely issues:
- `UIDevice.current.identifierForVendor` may require `import UIKit`
- `Map` API / annotation usage may need updating for the current SwiftUI/MapKit version
- Background geofence behavior may require authorization flow tightening
- The `authenticate` completion signature in `API.swift` is a bit awkward and may deserve cleanup
- `LocationManager` and `ContentView` may need small modernization fixes for the current SDK

## Architecture notes
- Backend service runs on Failsafe, not on the Mac
- Public hostname `arch.projectveritos.com` currently points to the Location Warden API
- Health endpoint is confirmed working externally

## Success criteria
GLaDOS is done when:
- The Xcode project opens cleanly
- The app builds successfully
- Zoe can run it on iPhone
- The app can hit `/health` and `/location/zones`
- The project no longer depends on the broken generated `.xcodeproj`

## Nice-to-have
If time permits, GLaDOS can also:
- make the zone placement UX nicer
- improve error states / connection messaging
- make server URL configurable in one obvious place
- add a simple test zone flow
