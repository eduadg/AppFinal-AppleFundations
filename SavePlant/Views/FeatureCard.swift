import SwiftUI
import UIKit

public struct FeatureCard: View {
    let title: String
    let systemImage: String
    let gradient: LinearGradient
    let roundedCorners: UIRectCorner
    let bgImageName: String?
    
    public init(title: String,
                systemImage: String,
                gradient: LinearGradient,
                roundedCorners: UIRectCorner,
                bgImageName: String? = nil) {
        self.title = title
        self.systemImage = systemImage
        self.gradient = gradient
        self.roundedCorners = roundedCorners
        self.bgImageName = bgImageName
    }
    
    public var body: some View {
        ZStack {
            // Fundo: imagem ou gradient
            if let name = bgImageName, let ui = UIImage(named: name) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                gradient
            }
            
            // Overlay escuro para melhorar contraste do texto
            Rectangle()
                .fill(Color.black.opacity(0.3))
            
            // Sombra no rodapé para dar contraste
            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .top, endPoint: .bottom
            )
            
            // Conteúdo do card (título sempre visível)
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundColor(.white)
                        .shadow(radius: 3)
                    if title == "Doenças" {
                        Image(systemName: "cross.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .bold))
                    } else if title == "Inspirations" {
                        Image(systemName: "sparkles")
                            .foregroundColor(.white)
                    } else if title == "Find A Plant" {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.black.opacity(0.9), in: Capsule())
                .padding(.bottom, 16)
                .padding(.horizontal, 12)
            }
        }
        .frame(height: 146)
        .cornerRadius(26, corners: roundedCorners)
        .shadow(color: Color.black.opacity(0.07), radius: 10, x: 0, y: 6)
    }
}

