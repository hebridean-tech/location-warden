import SwiftUI

struct BodyView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "heart.text.clipboard")
                .font(.system(size: 48))
                .foregroundColor(.raphAccent.opacity(0.5))
            Text("Coming soon")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.raphTextSecondary)
            Text("Body tracking and wellness metrics\nwill appear here.")
                .font(.subheadline)
                .foregroundColor(.raphTextSecondary.opacity(0.7))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.raphBackground)
        .navigationTitle("Body")
        .navigationBarTitleDisplayMode(.inline)
    }
}
