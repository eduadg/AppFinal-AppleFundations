import SwiftUI

public struct PrimaryButtonStyle: ButtonStyle {
    public var height: CGFloat = 56
    public init(height: CGFloat = 56) { self.height = height }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: height)
            .padding(.horizontal, 12)
            .background(DS.ColorSet.brand)
            .clipShape(Capsule())
            .overlay( // leve brilho superior (bevel)
                Capsule()
                    .strokeBorder(.white.opacity(0.35), lineWidth: 1)
                    .blendMode(.overlay)
                    .opacity(0.5)
            )
            .shadow(color: DS.Shadow.soft, radius: 12, x: 0, y: 8)
            .opacity(configuration.isPressed ? 0.92 : 1)
    }

}

