import SwiftUI

public struct EnciclopediaView: View {
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.99, blue: 0.98),
                        Color(red: 0.94, green: 0.97, blue: 0.95),
                        Color(red: 0.92, green: 0.95, blue: 0.93)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: DS.Spacing.lg) {
                    Spacer()
                    
                    Image(systemName: "book.pages.fill")
                        .font(.system(size: 64))
                        .foregroundColor(DS.ColorSet.textSecondary)
                    
                    VStack(spacing: DS.Spacing.sm) {
                        Text("Enciclopédia")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(DS.ColorSet.textPrimary)
                        
                        Text("Doenças e Tratamentos")
                            .font(.body)
                            .foregroundColor(DS.ColorSet.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, DS.Spacing.xl)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Enciclopédia")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
