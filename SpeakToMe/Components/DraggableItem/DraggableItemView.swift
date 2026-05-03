import SwiftUI

struct DraggableItemView: View {
    let title: String
    let emoji: String
    let onDropSuccess: () -> Void

    @State private var offset: CGSize = .zero

    var body: some View {
        VStack(spacing: 10) {
            Text("Help me move it")
                .font(.headline)
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.7))
                    .frame(height: 140)

                Text("Drop Here")
                    .font(.title3.bold())
                    .foregroundStyle(AppTheme.indigo)
                    .offset(x: 120)

                Text("\(emoji) \(title)")
                    .font(.title2)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.yellow.opacity(0.9), in: Capsule())
                    .offset(offset)
                    .gesture(
                        DragGesture()
                            .onChanged { offset = $0.translation }
                            .onEnded { value in
                                if value.translation.width > 90 {
                                    onDropSuccess()
                                    offset = .zero
                                } else {
                                    withAnimation(.spring()) { offset = .zero }
                                }
                            }
                    )
            }
        }
        .worldCard()
    }
}
