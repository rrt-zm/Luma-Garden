import SwiftUI

struct LumaScreen<Content: View>: View {
    @Environment(\.luma) private var luma
    @Environment(\.dismiss) private var dismiss
    var title: String
    var subtitle: String?
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button { dismiss() } label: {
                    GlyphView(glyph: .quests, size: 18, color: luma.primary)
                        .rotationEffect(.degrees(180))
                        .padding(10)
                        .background(Circle().fill(luma.panel))
                }
                .buttonStyle(PressableStyle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(LumaFont.display(22)).foregroundStyle(luma.text)
                    if let subtitle {
                        Text(subtitle).font(LumaFont.body(12)).foregroundStyle(luma.textSoft)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 8)

            content
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}
