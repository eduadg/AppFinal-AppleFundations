import SwiftUI

public struct TipsCarousel: View {
    let items: [TipItem]
    
    public init(items: [TipItem]) {
        self.items = items
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: DS.Spacing.md) {
                ForEach(items, id: \.id) { tip in
                    TipsCard(tip: tip)
                        .frame(width: 280)
                }
            }
            .padding(.horizontal, DS.Spacing.md)
        }
    }
}

struct TipsCard: View {
    let tip: TipItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            // Título da dica
            Text(tip.title)
                .font(.headline.weight(.semibold))
                .foregroundColor(DS.ColorSet.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Descrição
            Text(tip.description)
                .font(.body)
                .foregroundColor(DS.ColorSet.textSecondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            Spacer(minLength: 0)
        }
        .padding(DS.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: 120)
        .background(Color.white)
        .cornerRadius(DS.Radius.lg)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}


