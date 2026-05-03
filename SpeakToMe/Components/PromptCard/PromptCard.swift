import SwiftUI

struct PromptCard: View {
    let mascot: String
    let prompt: String
    let helper: String

    var body: some View {
        HStack(spacing: 16) {
            Text(mascot)
                .font(.system(size: 58))

            VStack(alignment: .leading, spacing: 8) {
                Text(prompt)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AppTheme.highContrastText)
                Text(helper)
                    .font(.headline)
                    .foregroundStyle(AppTheme.indigo)
            }
            Spacer()
        }
        .worldCard()
    }
}
