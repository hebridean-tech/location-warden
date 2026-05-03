# V1 Rune Chat — Scope

## What it is

A dedicated chat tab in Aperture for messaging Rune directly, separate from the location/status tab.

## Current status

### Real (V1.1)
- **Real HTTP transport** — app sends messages via `POST /chat/send` to the Aperture backend
- **Backend chat API** — three new endpoints on Failsafe:
  - `POST /chat/send` — stores user message + appends to `chat_pending.jsonl` for OpenClaw pickup
  - `GET /chat/messages/{device_id}?since=<epoch>&limit=N` — fetches messages (user + agent)
  - `POST /chat/reply?device_id=...&text=...` — stores an agent reply (for OpenClaw or external tools)
- **Reply polling** — app polls for agent replies with exponential backoff (1s → 8s, up to ~15s total), then shows a fallback message
- **SQLite persistence** on backend — `chat_messages` table with device/thread isolation
- Message persistence on app via UserDefaults (unchanged)

### Staged (not yet wired)
- **OpenClaw session injection** — `chat_pending.jsonl` is written but no OpenClaw cron/heartbeat consumer reads it yet. Next step: a watcher that reads pending messages, injects them into an OpenClaw session, and calls `POST /chat/reply` with the response.
- **Push notifications** — app still polls; WebSocket or push not yet implemented
- **Multiple agents** — model supports `agentId` but UI is Rune-only

### Architecture
```
App (iOS)                         Backend (Failsafe)              OpenClaw (Rune)
  │                                   │                              │
  ├─ POST /chat/send ──────────────►  │                              │
  │                                   ├─ INSERT chat_messages         │
  │                                   ├─ APPEND chat_pending.jsonl ──►│ (staged)
  │                                   │                              │
  ├─ GET /chat/messages?since=... ──► │                              │
  │   (poll every 1-8s)               │                              │
  │                                   │◄── POST /chat/reply ────────┤ (staged)
  │◄── [{id, text, is_from_user}] ───┤                              │
  │                                   │                              │
```

## Transport classes
- `ChatTransport` (protocol) — swap point
- `RealChatTransport` — default, talks to backend via HTTP
- `MockChatTransport` — kept for offline/testing fallback

## Next steps
1. Wire an OpenClaw consumer for `chat_pending.jsonl` → inject into session → POST /chat/reply
2. Add per-agent tab or conversation picker (LW-016)
3. Wire zone-based alerts into the chat (LW-014)
