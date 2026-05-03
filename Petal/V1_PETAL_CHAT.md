# Raphtalia v1 — Chat via Madame Sévérine

## Overview
Raphtalia is a personal wellness and task management app with an integrated chat interface to Madame Sévérine, powered by OpenClaw's `/v1/responses` proxy.

## Architecture

### Transport
- `RealChatTransport` — sends POST to `/v1/responses` with `{"input": text, "model": "openclaw", "stream": false}`
- Auth via shared token from `location_warden_token` (same auth flow as Aperture)
- Response parsing: OpenAI Responses format (`output[].content[].text`)

### Chat
- Agent: `madame` (Madame Sévérine)
- Storage: `UserDefaults` key `aperture_chat_madame_messages`
- Model: `ChatMessage` (id, agentId, text, timestamp, isFromUser)

### Location
- `LocationManager` unchanged from Aperture — zone monitoring, event posting
- Integrated subtly into HomeView dashboard

### Tasks
- Mock chore data (6 daily tasks, tap-to-complete)
- Outfit/wardrobe tracker (available/dirty/clean, laundry reset)
- Persisted via UserDefaults

## Tabs
1. **Home** — Dashboard with greeting, date, location status, chores summary
2. **Tasks** — Chore checklist + outfit selector
3. **Body** — Placeholder
4. **Progress** — Placeholder
5. **Chat** — Full messaging to Madame Sévérine

## Design
- Soft feminine palette: dusty rose accent, sage green secondary
- Light gray backgrounds, white cards with subtle shadows
- Spring animations on task completion
