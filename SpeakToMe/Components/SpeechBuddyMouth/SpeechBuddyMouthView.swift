import SwiftUI

struct SpeechBuddyMouthView: View {
    let targetText: String
    let phonemes: [String]
    let syllables: [String]
    let visemes: [String]

    @State private var currentIndex = 0
    @State private var slowMode = false

    private var currentViseme: MouthShape {
        MouthAnimationEngine.shape(for: visemes[safe: currentIndex] ?? "openMouth")
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Watch my mouth")
                .font(.title3.bold())
                .foregroundStyle(AppTheme.highContrastText)

            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.35))
                    .frame(width: 150, height: 150)

                VStack(spacing: 8) {
                    HStack(spacing: 26) {
                        Circle().fill(Color.black).frame(width: 10, height: 10)
                        Circle().fill(Color.black).frame(width: 10, height: 10)
                    }
                    mouthView(for: currentViseme)
                }
            }

            Text("\"\(targetText)\"")
                .font(.title3)

            HStack(spacing: 8) {
                tagRow(title: "Phonemes", values: phonemes)
                tagRow(title: "Syllables", values: syllables)
            }

            HStack(spacing: 12) {
                Button("Replay Model") {
                    currentIndex = 0
                    animateSequence()
                }
                .buttonStyle(.borderedProminent)

                Button(slowMode ? "Normal Speed" : "Slow Speed") {
                    slowMode.toggle()
                    animateSequence()
                }
                .buttonStyle(.bordered)
            }

            Text("Let's do it together.")
                .font(.headline)
                .foregroundStyle(AppTheme.coral)
        }
        .worldCard()
        .task {
            animateSequence()
        }
    }

    @ViewBuilder
    private func mouthView(for shape: MouthShape) -> some View {
        switch shape {
        case .closedLips:
            Capsule().fill(Color.red).frame(width: 72, height: 12)
        case .openMouth:
            Ellipse().fill(Color.red).frame(width: 58, height: 42)
        case .smileMouth:
            Capsule().stroke(Color.red, lineWidth: 6).frame(width: 80, height: 22)
        case .teethOnLip:
            VStack(spacing: 0) {
                Rectangle().fill(.white).frame(width: 62, height: 10)
                Capsule().fill(Color.red).frame(width: 62, height: 14)
            }
        case .tongueUp, .tongueBetweenTeeth:
            ZStack {
                Ellipse().fill(Color.red).frame(width: 62, height: 32)
                Capsule().fill(Color.pink).frame(width: 30, height: 10)
            }
        case .teethClose:
            Rectangle().fill(.white).frame(width: 68, height: 10)
        case .roundedLips, .roundedTensed:
            Circle().stroke(Color.red, lineWidth: 6).frame(width: 42, height: 42)
        case .backSound:
            RoundedRectangle(cornerRadius: 8).fill(Color.red).frame(width: 50, height: 34)
        }
    }

    private func tagRow(title: String, values: [String]) -> some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption.bold())
            Text(values.prefix(4).joined(separator: " • "))
                .font(.caption)
                .lineLimit(2)
        }
        .padding(8)
        .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 12))
    }

    private func animateSequence() {
        guard !visemes.isEmpty else { return }
        currentIndex = 0

        Task {
            let delay = slowMode ? 0.45 : 0.22
            for idx in visemes.indices {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: delay)) {
                        currentIndex = idx
                    }
                }
                try? await Task.sleep(for: .seconds(delay))
            }
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
