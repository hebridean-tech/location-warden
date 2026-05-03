# V1 Rune Chat — Scope

## What it is

A dedicated chat tab in Aperture for messaging Rune directly, separate from the location/status tab.

## In scope (V1)

- Separate "Rune" tab in the tab bar
- Single conversation thread with Rune
- Message input field + send button
- Scrollable message history (user & Rune bubbles)
- Message persistence via UserDefaults (survives app restart)
- Mock transport that returns placeholder replies (staged for real backend swap)
- Clean architecture: `ChatTransport` protocol, `ChatService` class, `ChatMessage` model — all designed for later multi-agent expansion

## Intentionally out of scope (V1)

- Real OpenClaw backend transport (WebSocket / HTTP polling) — swap `MockChatTransport` for a real implementation
- Multiple agent threads — the model supports it (`agentId` field, `AgentIdentity` struct) but UI shows only Rune for now
- Push notifications for new messages
- Rich content (images, voice, action cards)
- Message search or history management UI
- Streaming/typing indicators

## Architecture notes

```
ChatTransport (protocol)  ← swap mock for real
  └── MockChatTransport   ← V1 placeholder
  └── (future: OpenClawChatTransport)

ChatService (ObservableObject, @MainActor)
  └── messages: [ChatMessage]
  └── send(_:) → transport.send → appends reply
  └── UserDefaults persistence (keyed per agent thread)

ChatView
  └── ScrollView + LazyVStack of MessageBubble
  └── Input bar with TextField + send button

ContentView (TabView)
  ├── Location tab → LocationView (existing)
  └── Rune tab → ChatView (new)
```

## Next steps

1. Implement `OpenClawChatTransport` that talks to a real backend endpoint
2. Add per-agent tab or conversation picker (LW-016)
3. Wire zone-based alerts into the chat (LW-014)
