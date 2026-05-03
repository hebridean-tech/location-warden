import SwiftUI

struct ChatView: View {
    @StateObject private var chat = ChatService.shared
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        if chat.messages.isEmpty {
                            VStack(spacing: 12) {
                                Text("No messages yet.")
                                    .foregroundColor(.raphTextSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 60)
                                Text("Say hello.")
                                    .font(.subheadline)
                                    .foregroundColor(.raphTextSecondary.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                        }
                        ForEach(chat.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: chat.messages.count) { _ in
                    if let last = chat.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
                .onAppear {
                    if let last = chat.messages.last {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }
            }
            .onTapGesture {
                isInputFocused = false
            }

            Divider()

            // Typing indicator
            if chat.isSending {
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color.raphAccent.opacity(0.6))
                            .frame(width: 8, height: 8)
                            .modifier(PulsingDot(delay: Double(index) * 0.2))
                    }
                    Text("Madame Sévérine is typing…")
                        .font(.caption)
                        .foregroundColor(.raphTextSecondary)
                }
                .padding(.horizontal, 12)
                .transition(.opacity)
            }

            Divider()

            // Input bar
            HStack(alignment: .center) {
                TextField("Message Madame Sévérine…", text: $inputText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...5)
                    .focused($isInputFocused)
                    .onSubmit { send() }

                Button(action: send) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : Color.raphAccent)
                }
                .disabled(chat.isSending || inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.bar)
        }
        .background(Color.raphBackground)
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func send() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        isInputFocused = false
        chat.send(text)
    }
}

// MARK: - Typing indicator animation

struct PulsingDot: ViewModifier {
    let delay: Double
    @State private var animating = false

    func body(content: Content) -> some View {
        content
            .opacity(animating ? 0.3 : 1.0)
            .scaleEffect(animating ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(delay), value: animating)
            .onAppear { animating = true }
    }
}

// MARK: - Message bubble

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromUser { Spacer(minLength: 48) }
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 2) {
                Text(message.text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(message.isFromUser ? Color.raphAccent : Color(.systemGray5))
                    .foregroundColor(message.isFromUser ? .white : .raphTextPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                Text(message.formattedTime)
                    .font(.caption2)
                    .foregroundColor(.raphTextSecondary)
            }
            if !message.isFromUser { Spacer(minLength: 48) }
        }
    }
}
