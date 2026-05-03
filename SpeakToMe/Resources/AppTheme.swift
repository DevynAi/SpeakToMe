import SwiftUI

enum AppTheme {
    static let skyTop = Color(red: 0.40, green: 0.73, blue: 0.98)
    static let skyBottom = Color(red: 0.80, green: 0.93, blue: 0.99)
    static let grass = Color(red: 0.46, green: 0.80, blue: 0.40)
    static let sun = Color(red: 1.0, green: 0.84, blue: 0.34)
    static let coral = Color(red: 0.98, green: 0.47, blue: 0.35)
    static let indigo = Color(red: 0.24, green: 0.35, blue: 0.82)
    static let highContrastText = Color.black

    static let worldGradient = LinearGradient(
        colors: [skyTop, skyBottom, grass.opacity(0.4)],
        startPoint: .top,
        endPoint: .bottom
    )
}

struct WorldCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white.opacity(0.92))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(AppTheme.indigo.opacity(0.2), lineWidth: 2)
                    )
            )
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }
}

extension View {
    func worldCard() -> some View {
        modifier(WorldCardStyle())
    }
}
