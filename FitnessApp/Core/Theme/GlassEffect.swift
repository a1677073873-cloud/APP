import SwiftUI

struct GlassEffect: ViewModifier {
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
            )
    }
}

struct WhiteCard: ViewModifier {
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.pureWhite)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.lightGray, lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, y: 2)
    }
}

extension View {
    func glassEffect(cornerRadius: CGFloat = 16, padding: CGFloat = 16) -> some View {
        modifier(GlassEffect(cornerRadius: cornerRadius, padding: padding))
    }

    func whiteCard(cornerRadius: CGFloat = 16, padding: CGFloat = 16) -> some View {
        modifier(WhiteCard(cornerRadius: cornerRadius, padding: padding))
    }
}
