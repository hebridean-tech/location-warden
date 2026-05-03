import SwiftUI

struct ProgressView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(.raphSage.opacity(0.5))
            Text("Coming soon")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.raphTextSecondary)
            Text("Your progress and streaks\nwill be tracked here.")
                .font(.subheadline)
                .foregroundColor(.raphTextSecondary.opacity(0.7))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.raphBackground)
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.inline)
    }
}
