# Location Warden Product Spec

## Product summary

Location Warden is a private iPhone app that acts as Zoe's OpenClaw mobile companion.

It combines:
- presence and location awareness
- direct agent messaging
- context-aware actions
- push alerts and nudges
- lightweight day-management support

It should feel like a trusted personal control surface for Rune, Ivy, GLaDOS, and other agents, not just a location tracker.

## Product goals

1. Let Zoe's phone securely inform OpenClaw where he is and what context he is in.
2. Give Zoe a private, native alternative to Telegram for interacting with agents.
3. Let agents proactively help based on location, schedule, timing, and routines.
4. Keep the experience fast, low-friction, and trustworthy.

## Non-goals

At least for early versions, Location Warden is not:
- a full maps app
- a social location-sharing app
- a generic team chat app
- a high-frequency live tracker
- a bloated mobile dashboard full of admin clutter

## Core design principles

- **Presence-first**: know where Zoe is, what he is doing, and what matters now.
- **Agent-centered**: the app exists to improve agent usefulness, not to duplicate every other app.
- **Context-aware**: surface the right action at the right time.
- **Private and trusted**: this is a personal system, not a public network.
- **Calm by default**: only interrupt when it helps.

## Primary user

- Zoe, on iPhone first

## Secondary system actors

- Rune
- Ivy
- GLaDOS
- future OpenClaw agents

## Key use cases

### 1. Gym arrival workflow
When Zoe arrives at the gym, the app informs the backend. Rune can then tell him what workout he should do that day.

### 2. Calendar lateness workflow
Ivy uses location and timing context to determine whether Zoe is likely to be late, early, or on time for calendar events.

If an event is due soon and Zoe is still at Home, Ivy can optionally send a late text on his behalf.

This depends on calendar events carrying usable location data so commute/travel time can be inferred.

### 3. Direct agent messaging
Zoe can message agents directly from the app instead of relying on Telegram.

### 4. Contextual suggestions
The app surfaces suggested actions based on zone, schedule, and routines.

### 5. Trusted mobile control surface
The phone acts as a known personal device for sending secure requests to OpenClaw.

### 6. TTS alarm clock and wake briefings
The app can deliver spoken wake-up alerts and morning briefings, including traffic-aware guidance on when Zoe needs to get out of bed to make his next appointment.

## Feature set

## Must-have features

### Presence and location
- geofence zone management
- enter/exit event reporting
- current-zone detection on app launch
- manual location sync
- current status view

### Agent communication
- direct chat with Rune
- ability to expand later to multiple agents
- receive agent replies in-app
- zone-configurable agent alert routing

### Notifications
- app-native push notifications
- Ivy lateness alerts
- Rune context nudges
- spoken alarm and wake-up briefings

### Context engine basics
- zone-based prompts
- event-aware suggestions
- gym and commute hooks
- per-zone arrival/departure alert rules

### Trust and auth
- device auth token
- trusted-device identity
- secure API communication with backend

## Nice-to-have features

### Richer presence
- motion state (walking/driving/stationary)
- ETA estimation
- recent location history
- battery-aware sync modes

### Better agent UX
- multi-agent inbox
- pinned quick actions
- reusable routines
- voice notes or audio requests
- spoken agent replies using the local TTS server
- full talking mode with speech-to-text in and text-to-speech out
- low-latency conversational voice mode optimized for short back-and-forth turns

### Daily command center
- next event
- next task
- what should I be doing now?
- focus mode / routine toggles
- commute and leave-now guidance
- wake-up timing guidance based on traffic and schedule
- event destination awareness from calendar location fields

### Workout support
- show today's workout
- log a workout session
- track arrival/completion notes

### Wake / morning automation
- spoken alarm clock behavior
- morning briefing read aloud
- traffic-aware leave-bed timing
- next appointment readiness guidance

### Admin/power features
- assign per-zone behaviors
- choose which agent handles which trigger
- per-notification routing
- Face ID gate for sensitive actions
- custom per-zone agent alert settings
- trusted-device approvals

## Screen list

### 1. Home
Shows current status and most relevant actions.

Contents:
- current zone
- next event
- current timing status
- suggested actions
- recent agent nudge

### 2. Agents
Entry point for direct agent messaging.

Contents:
- Rune thread
- Ivy thread
- GLaDOS thread
- future agents
- optional talking mode entry point

### 3. Zones
Manage geofences and attach behaviors.

Contents:
- list of zones
- add/edit/delete zone
- attach action/rule per zone
- toggle agent alerts per zone
- select target agent per zone
- choose arrival / departure / both triggers per zone

### 4. Today
Shows the current day context.

Contents:
- next calendar event
- timing / lateness status
- key tasks
- recommended next action

### 5. Settings
Controls trust, sync, notifications, and behavior.

Contents:
- device identity
- notification settings
- background behavior
- API/backend status
- privacy controls

## V1 scope cutoff

V1 should stay small and reliable.

### V1 includes
- iPhone app
- geofence zones
- enter/exit posting
- current-zone detection on app launch
- basic backend sync
- current status screen
- manual sync button

### V1 may include if easy
- one direct Rune chat thread
- one gym shortcut
- one Ivy lateness endpoint

### V1 excludes
- full multi-agent inbox
- complete push notification system
- advanced ETA engine
- complex workflow builder
- continuous live tracking

## V2 scope

- Rune in-app chat
- push notifications
- gym workflow fully wired
- Ivy lateness logic wired
- contextual quick actions

## V3 scope

- multi-agent messaging
- Today screen
- richer presence model
- task/calendar integration
- better trust and approval flows
- spoken agent replies via local TTS
- talking mode (STT in, TTS out)
- low-latency conversational voice mode
- spoken morning alarm/briefing mode

## Technical architecture

### App
- SwiftUI iPhone app
- CoreLocation geofencing
- background location support
- secure token-based API communication

### Backend
- FastAPI on Failsafe
- SQLite for recent presence/event data
- public HTTPS endpoint via `arch.projectveritos.com`
- later event-forwarding into OpenClaw agent workflows

### OpenClaw integration
Planned integration layers:
- receive app-originated events
- route event context to Rune/Ivy
- support in-app agent chat
- support notifications back to the device

## Main technical gaps to solve next

1. Event forwarding from backend into OpenClaw agent workflows
2. Current-zone detection even without boundary crossing
3. In-app chat protocol for agent messaging
4. Push notification delivery path
5. trusted-device authentication model
6. per-zone configurable alert settings model
7. Ivy lateness workflow with optional outbound text-on-behalf behavior
8. spoken reply pipeline using the local TTS server
9. talking mode pipeline with speech-to-text input and low-friction turn handling
10. low-latency conversational tuning for short-turn voice interaction, ideally with streaming or near-streaming reply behavior
11. spoken alarm clock / morning briefing pipeline with traffic and schedule-aware wake guidance
12. calendar event location support sufficient for destination-aware commute logic

## Product risks

- iOS background behavior can be finicky
- too much scope too early could make the app messy
- chat, notifications, and location together need careful privacy handling
- agent integration should not depend on brittle polling hacks

## Recommendation

Build the product in this order:

1. rock-solid presence and geofencing
2. current-zone detection and manual sync
3. Rune chat thread in-app
4. Ivy lateness and gym workflows
5. push notifications
6. multi-agent expansion
7. trusted-device approvals
8. spoken agent replies
9. spoken morning briefing and alarm behavior

This keeps the app useful early while leaving room for it to become Zoe's real OpenClaw mobile companion.
