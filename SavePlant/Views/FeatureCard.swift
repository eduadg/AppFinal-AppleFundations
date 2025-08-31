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
            // Fundo
            backgroundView
            
            // Texto sobreposto - SEMPRE VISÍVEL
            textOverlay
        }
        .frame(height: 146)
        .cornerRadius(26, corners: roundedCorners)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        if let imageName = bgImageName {
            // Tentar carregar a imagem
            if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .overlay(Color.black.opacity(0.5)) // Overlay escuro direto
            } else {
                // Fallback se a imagem não carregar
                gradient
                    .overlay(
                        Text("IMG NOT FOUND")
                            .foregroundColor(.red)
                            .font(.caption)
                    )
            }
        } else {
            gradient
        }
    }
    
    private var textOverlay: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 8) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)
                
                iconForTitle
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.9))
            .cornerRadius(25)
            .padding(.bottom, 16)
            .padding(.horizontal, 16)
        }
    }
    
    @ViewBuilder
    private var iconForTitle: some View {
        switch title {
        case "Doenças":
            Image(systemName: "cross.circle.fill")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
        case "Inspirations":
            Image(systemName: "sparkles")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
        case "Find A Plant":
            Image(systemName: "magnifyingglass.circle.fill")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
        default:
            Image(systemName: systemImage)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
        }
    }
}