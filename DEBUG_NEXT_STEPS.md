# Aperture debug next steps

## What was added
The app source now exposes more presence/debug information in the main status screen:
- device ID
- last known coordinate
- last post status
- monitored region names
- manual current-location sync button
- manual test event button

## What to do on the phone
1. Install a build that includes the latest source changes.
2. Open the app.
3. Confirm the status screen shows:
   - a real device ID
   - monitored regions
   - post status updates
4. Tap **Sync current location**.
5. Tap **Send test event**.
6. Travel across a zone boundary and watch whether:
   - current zone updates
   - last post status changes
   - backend receives the event

## What to verify from backend
Use the device ID shown in the app and query the backend for that specific history/status instead of `unknown`.

## Likely questions this will answer
- Is the app using the expected device ID?
- Is current-zone sync posting successfully?
- Are geofences actually being registered?
- Are geofence callbacks firing but failing to post?
- Is the app only posting some zones and not others?
