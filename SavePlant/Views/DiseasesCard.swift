import SwiftUI
import UIKit

public struct DiseasesCard: View {
    public init() {}
    
    public var body: some View {
        // Card específico para doenças - abordagem mais direta
        Rectangle()
            .fill(Color.clear)
            .frame(height: 146)
            .background(
                Group {
                    if let uiImage = UIImage(named: "Doenças") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        LinearGradient(
                            colors: [
                                Color(red: 0.22, green: 0.36, blue: 0.29),
                                Color(red: 0.10, green: 0.33, blue: 0.26)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
            )
            .clipped()
            .overlay(
                // Texto SEMPRE visível
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Text("Doenças")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.white)
                        
                        Image(systemName: "cross.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .bold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.9))
                    .cornerRadius(25)
                    .padding(.bottom, 16)
                    .padding(.horizontal, 16)
                },
                alignment: .bottom
            )
            .overlay(
                Color.black.opacity(0.4)
            )
            .cornerRadius(26, corners: [.topLeft, .bottomRight])
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
