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
                .fill(Color.black.opacity(0.4))
            
            // Conteúdo do card (título sempre visível)
            VStack {
                Spacer()
                
                // Debug: texto sempre visível para testar
                Text("DEBUG: \(title)")
                    .font(.caption)
                    .foregroundColor(.red)
                    .background(Color.yellow)
                    .padding(4)
                
                HStack(spacing: 8) {
                    Text(title)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.white)
                        .shadow(radius: 4)
                    if title == "Doenças" {
                        Image(systemName: "cross.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .bold))
                    } else if title == "Inspirations" {
                        Image(systemName: "sparkles")
                            .foregroundColor(.white)
                    } else if title == "Find A Plant" {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .background(Color.black.opacity(0.95), in: Capsule())
                .padding(.bottom, 20)
                .padding(.horizontal, 16)
            }
        }
        .frame(height: 146)
        .cornerRadius(26, corners: roundedCorners)
        .shadow(color: Color.black.opacity(0.07), radius: 10, x: 0, y: 6)
    }
}

