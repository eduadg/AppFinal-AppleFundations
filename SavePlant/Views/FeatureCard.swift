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
            // Camada de fundo
            Group {
                if let imageName = bgImageName, let uiImage = UIImage(named: imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    gradient
                }
            }
            .clipped()
            
            // Overlay escuro para contraste
            Color.black.opacity(0.4)
            
            // Texto sempre visível
            VStack {
                Spacer()
                
                HStack(spacing: 8) {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundColor(.white)
                    
                    // Ícone baseado no título
                    Group {
                        if title.contains("Doenças") || title == "Doenças" {
                            Image(systemName: "cross.circle.fill")
                        } else if title.contains("Inspirations") {
                            Image(systemName: "sparkles")
                        } else if title.contains("Find") {
                            Image(systemName: "magnifyingglass.circle.fill")
                        } else {
                            Image(systemName: systemImage)
                        }
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.8))
                .cornerRadius(25)
                .padding(.bottom, 16)
                .padding(.horizontal, 16)
            }
        }
        .frame(height: 146)
        .cornerRadius(26, corners: roundedCorners)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}