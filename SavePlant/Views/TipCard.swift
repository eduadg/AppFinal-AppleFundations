import SwiftUI

public struct TipCard: View {
    let title: String
    let icon: String
    let color: Color
    
    public init(title: String, icon: String, color: Color) {
        self.title = title
        self.icon = icon
        self.color = color
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            // Ícone no topo
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            // Título na parte inferior
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
        }
        .padding(12)
        .frame(width: 140, height: 100)
        .background(
            LinearGradient(
                colors: [color.opacity(0.8), color],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
