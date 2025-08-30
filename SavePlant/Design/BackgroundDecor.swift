import SwiftUI

public struct BackgroundDecor: View {
    public init() {}
    public var body: some View {
        ZStack {
            LinearGradient(
                colors: [.white, DS.ColorSet.brandMuted.opacity(0.18)],
                startPoint: .top, endPoint: .bottom
            )

            // Se você adicionar uma imagem "leavesPattern" nos Assets, ela será usada.
            if let ui = UIImage(named: "leavesPattern") {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .opacity(0.10)
                    .ignoresSafeArea()
                    .blendMode(.multiply)
                    .padding(.top, 120)
                    .padding(.trailing, 12)
            }
        }
        .ignoresSafeArea()
    }
}

