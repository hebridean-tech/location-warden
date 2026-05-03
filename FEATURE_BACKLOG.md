# Aperture Feature Backlog

## Priority legend
- **P0** = required foundation
- **P1** = important near-term value
- **P2** = strong enhancement
- **P3** = future expansion

---

## P0 - foundation

### LW-001 Fresh working iOS project
Create and maintain a valid Xcode project that builds cleanly on Zoe's Mac and runs on iPhone.

**Why**
No product exists until the app builds and launches reliably.

**Done when**
- Xcode project opens cleanly
- app builds to device
- signing works
- required capabilities are configured

---

### LW-002 Reliable backend connection
Ensure the app can connect to `https://arch.projectveritos.com` and authenticate successfully.

**Why**
Everything depends on backend communication.

**Done when**
- `/health` reachable from device
- auth token flow works
- app handles unreachable backend gracefully

---

### LW-003 Zone CRUD
Allow creation, listing, editing, and deletion of zones.

**Why**
Zones are the foundation of presence logic.

**Done when**
- add zone works
- delete zone works
- edit zone works or is intentionally deferred with documented limitation
- zone list loads correctly

---

### LW-004 Geofence registration
Register saved zones with iOS so background enter/exit detection works.

**Why**
Without monitored regions, the app is not useful.

**Done when**
- zones become monitored regions
- registration survives relaunch
- failures are surfaced in logs/UI as needed

---

### LW-005 Enter/exit event posting
Post geofence enter/exit events to the backend.

**Why**
This is the first real presence signal.

**Done when**
- enter events post successfully
- exit events post successfully
- event payloads identify device and zone

---

### LW-006 Current-zone detection on launch
When the app opens, determine whether Zoe is already inside a known zone and report that state.

**Why**
Fixes the current limitation where nothing happens until a boundary is crossed.

**Done when**
- app can determine if current location is inside a configured zone
- backend receives a usable current-state update

---

### LW-007 Manual sync button
Provide a user-triggered “sync my current location/status” action.

**Why**
Gives a fallback when iOS background behavior is delayed.

**Done when**
- button exists
- it forces a current-state sync
- success/failure is visible to the user

---

### LW-008 Permission and onboarding flow
Handle location permission clearly and correctly.

**Why**
If Zoe does not grant the right permission, background behavior fails silently.

**Done when**
- app requests permission properly
- app explains why Always permission is needed
- app detects inadequate permission and guides correction

---

## P1 - early real value

### LW-009 Current status screen
Display current backend/app state in one simple view.

**Why**
Zoe needs confidence that the system is working.

**Done when**
- shows connection state
- shows current zone or last known state
- shows last event posted

---

### LW-010 Rune gym workflow hook
Create the app/backend hook for “at gym → ask Rune what workout today”.

**Why**
This is one of the core motivating use cases.

**Done when**
- gym arrival can trigger a workflow or endpoint
- Rune can consume that event path

---

### LW-011 Ivy lateness workflow hook
Create the app/backend hook for event timing and lateness checks.

**Why**
This is the second core motivating use case.

**Done when**
- backend can expose current place/time context for Ivy
- Ivy can determine likely on-time/late status
- groundwork exists for optional text-on-Zoe's-behalf behavior when he is still home near event time

---

### LW-012 Backend event forwarding to OpenClaw
Forward location events into OpenClaw workflows instead of only storing them.

**Why**
Makes the app actually useful to agents.

**Done when**
- event reaches OpenClaw automatically
- target workflow/agent can react

---

### LW-013 Better zone editing UX
Improve zone creation and editing flow.

**Why**
The app becomes annoying if location setup feels clumsy.

**Done when**
- map interaction feels acceptable
- editing a zone does not require awkward recreation
- zone settings include agent alert configuration
- radius is previewed live on the map during setup/editing
- small-radius zones below 50m are supported when needed

---

### LW-014 Per-zone agent alert settings
Allow each zone to define whether an agent is alerted, which agent is targeted, and whether alerts happen on arrival, departure, or both.

**Why**
Zone behavior should be user-configurable, not hardcoded.

**Done when**
- zone create/edit supports alert toggle
- user can choose target agent
- user can choose arrival/departure/both
- backend stores and returns these settings

---

## P2 - agent app evolution

### LW-015 In-app Rune chat
Add a direct Rune chat thread inside the app.

**Why**
Begins replacing Telegram for day-to-day agent communication.

**Done when**
- Zoe can send Rune a message in-app
- Rune's reply appears in-app

---

### LW-016 Agent inbox architecture
Generalize chat for multiple agents.

**Why**
Prepares the app to become a real OpenClaw companion.

**Done when**
- per-agent thread model exists
- at least Rune and Ivy can be represented cleanly

---

### LW-017 Contextual action cards
Show smart actions based on zone or schedule.

**Why**
Turns the app into a useful context surface, not just a tracker.

**Done when**
- app can show suggested actions on Home
- at least one gym and one schedule-based action works

---

### LW-018 Push notification pipeline
Allow agents/backend to send native push notifications.

**Why**
Essential for replacing Telegram as an alert surface.

**Done when**
- device can receive test push
- at least one agent alert reaches the phone

---

### LW-019 Recent event/history screen
Show recent location events and state changes.

**Why**
Helpful for debugging and trust.

**Done when**
- last several events are visible
- timestamps are understandable

---

## P3 - advanced expansion

### LW-020 Motion state awareness
Incorporate walking/driving/stationary context.

### LW-021 ETA and commute intelligence
Estimate travel timing to upcoming events.

### LW-022 Trusted-device approvals
Allow certain OpenClaw approvals/actions from the phone.

### LW-023 Face ID protection for sensitive actions
Add stronger local security for control actions.

### LW-024 Daily command center screen
Show today's tasks, events, and recommended next action.

### LW-025 Workout logging
Let Zoe mark workout progress or completion in-app.

### LW-026 Automation rule assignment
Assign specific behaviors or target agents per zone.

### LW-027 Ivy late-text workflow
If an event is due soon and Zoe is still home, let Ivy determine lateness and optionally send a text on his behalf.

### LW-028 Smart arrival/departure routines
Surface context-aware actions when Zoe leaves or arrives at key zones.

### LW-029 Agent push cards
Deliver actionable agent notifications with one-tap responses.

### LW-030 In-app command center
Provide a private mobile control surface for Rune, Ivy, GLaDOS, and other agents.

### LW-031 Shopping and errand awareness
Surface store-specific reminders, shopping lists, and errand prompts based on location.

### LW-032 Personal memory capture prompts
Prompt for short notes or memories when arriving at important places.

### LW-033 Spoken agent replies via local TTS
Allow agent replies to be played aloud using Zoe's local TTS server.

**Why**
Voice output could make the app feel more like a real companion and reduce the need to stare at the screen.

**Done when**
- app can request a spoken response variant
- backend can fetch/render audio from the local TTS server
- app can play agent voice replies inline or on demand

### LW-034 Talking mode (STT in, TTS out)
Provide a conversational voice mode similar to ChatGPT voice mode.

**Why**
This would make the app feel far more natural while driving, walking, or using the phone hands-free.

**Done when**
- user can hold a talk button or enter a voice mode
- speech is transcribed to text
- text is sent to the selected agent
- reply returns as audio via TTS
- conversation turn-taking feels reasonably smooth

### LW-035 Low-latency conversational voice mode
Tune the talking experience to feel as immediate and natural as possible.

**Why**
Zoe explicitly wants the app to feel highly conversational with low latency, not like a slow voice note system.

**Done when**
- STT runs natively on iPhone for fast input
- TTS uses Zoe's local TTS server for custom voices
- round-trip latency is kept low enough for natural short-turn conversation
- architecture is designed for streaming or near-streaming replies where practical
- voice mode is treated as a first-class UX, not just an add-on

### LW-036 TTS alarm clock and morning briefing
Use spoken audio to wake Zoe with a smart morning briefing.

**Why**
This extends the app from reactive assistant to proactive daily support, especially when traffic and schedule should influence wake timing.

**Done when**
- app can schedule a spoken alarm/briefing
- briefing can include next appointment context
- traffic/travel timing can influence recommended get-out-of-bed time
- spoken output uses Zoe's preferred TTS path

### LW-037 Calendar event location support
Add or require destination/location fields on calendar events so commute logic can infer travel needs.

**Why**
Commute intelligence, lateness detection, and wake timing all depend on knowing where an event actually is.

**Done when**
- event data model supports usable location/destination fields
- commute calculations can read those fields
- Ivy lateness and wake-up workflows can depend on them

---

## Recommended build order

### Immediate next build order
1. LW-001 Fresh working iOS project
2. LW-002 Reliable backend connection
3. LW-003 Zone CRUD
4. LW-004 Geofence registration
5. LW-005 Enter/exit event posting
6. LW-006 Current-zone detection on launch
7. LW-007 Manual sync button
8. LW-008 Permission and onboarding flow

### Then
9. LW-009 Current status screen
10. LW-012 Backend event forwarding to OpenClaw
11. LW-010 Rune gym workflow hook
12. LW-011 Ivy lateness workflow hook

### Then
13. LW-014 Per-zone agent alert settings
14. LW-015 In-app Rune chat
15. LW-017 Contextual action cards
16. LW-018 Push notification pipeline
17. LW-016 Agent inbox architecture
18. LW-027 Ivy late-text workflow
19. LW-029 Agent push cards
20. LW-030 In-app command center
21. LW-033 Spoken agent replies via local TTS
22. LW-034 Talking mode (STT in, TTS out)
23. LW-035 Low-latency conversational voice mode
24. LW-036 TTS alarm clock and morning briefing
25. LW-037 Calendar event location support

---

## Recommended V1 definition

V1 is complete when:
- the app builds and runs reliably
- Zoe can define zones
- geofence events post correctly
- current-zone sync works without needing a boundary crossing
- manual sync exists
- app status is visible and understandable

## Recommended V2 definition

V2 is complete when:
- backend events reach OpenClaw automatically
- Rune gym workflow works
- Ivy lateness workflow works
- per-zone agent alert settings work
- Rune can be messaged in-app or triggered from app actions

## Recommended V3 definition

V3 is complete when:
- the app meaningfully replaces part of Telegram for agent interaction
- push notifications work
- multiple agents are supported cleanly
- Home screen provides useful contextual actions
- spoken replies are available as an option
- a usable talking mode exists
- voice mode feels low-latency enough to be genuinely conversational
- a spoken morning briefing/alarm path is defined for later implementation
