import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(isEnabled ? Color(.systemBackground) : Color.secondary)
            .tint(Color(.systemBackground))
            .frame(minHeight: 52)
            .background(
                isEnabled ? AnyShapeStyle(.primary) : AnyShapeStyle(.fill.tertiary),
                in: Capsule()
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct FieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .frame(minHeight: 52)
            .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 14))
    }
}
