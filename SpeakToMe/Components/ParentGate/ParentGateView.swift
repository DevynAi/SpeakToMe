import SwiftUI

struct ParentGateView: View {
    @Binding var isUnlocked: Bool
    @State private var holdProgress: Double = 0
    @State private var answer = ""

    private let left = 4
    private let right = 2

    var body: some View {
        VStack(spacing: 16) {
            Text("Parent Gate")
                .font(.largeTitle.bold())
            Text("Hold the button for 3 seconds, then solve \(left) + \(right).")
                .font(.headline)
                .multilineTextAlignment(.center)

            ProgressView(value: holdProgress, total: 1)
                .tint(AppTheme.coral)
                .frame(maxWidth: 360)

            Button("Hold to continue") { }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 3)
                        .onChanged { _ in holdProgress = 1.0 }
                )

            TextField("Answer", text: $answer)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 160)

            Button("Unlock") {
                if Int(answer) == left + right && holdProgress >= 1 {
                    isUnlocked = true
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(20)
        .worldCard()
    }
}
