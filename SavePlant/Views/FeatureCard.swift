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
        // Usando a mesma estrutura que funcionou no DiseasesCard
        Rectangle()
            .fill(Color.clear)
            .background(
                Group {
                    if let imageName = bgImageName, let uiImage = UIImage(named: imageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        gradient
                    }
                }
            )
            .clipped()
            .overlay(
                // Texto SEMPRE visível - mesma estrutura que funcionou
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.headline.weight(.bold))
                            .foregroundColor(.white)
                        
                        Image(systemName: getIconName())
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .bold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.75))
                    .cornerRadius(25)
                    .padding(.bottom, 16)
                    .padding(.horizontal, 16)
                },
                alignment: .bottom
            )
            .overlay(
                // Gradiente sutil apenas na parte inferior para contraste do texto
                Group {
                    if bgImageName != nil {
                        LinearGradient(
                            colors: [.clear, .clear, .black.opacity(0.3)],
                            startPoint: .top, 
                            endPoint: .bottom
                        )
                    } else {
                        Color.clear
                    }
                }
            )
            .cornerRadius(26, corners: roundedCorners)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private func getIconName() -> String {
        switch title {
        case "Doenças":
            return "cross.circle.fill"
        case "Inspirations":
            return "sparkles"
        case "Find A Plant":
            return "magnifyingglass.circle.fill"
        default:
            return systemImage
        }
    }
}