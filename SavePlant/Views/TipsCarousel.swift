import SwiftUI

public struct TipsCarousel: View {
    let items: [TipItem]
    @State private var expandedCardIndex: Int? = nil
    
    public init(items: [TipItem]) {
        self.items = items
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: DS.Spacing.md) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, tip in
                    TipsCard(
                        tip: tip,
                        isExpanded: expandedCardIndex == index,
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                expandedCardIndex = expandedCardIndex == index ? nil : index
                            }
                        }
                    )
                    .frame(width: expandedCardIndex == index ? 320 : 280)
                }
            }
            .padding(.horizontal, DS.Spacing.md)
        }
    }
}

struct TipsCard: View {
    let tip: TipItem
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                HStack {
                    // Ícone da dica
                    Image(systemName: tip.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(DS.ColorSet.brand)
                        .frame(width: 32, height: 32)
                        .background(DS.ColorSet.brandMuted)
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    // Indicador de expansão
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(DS.ColorSet.textSecondary)
                }
                
                // Título da dica
                Text(tip.title)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(DS.ColorSet.textPrimary)
                    .lineLimit(isExpanded ? nil : 2)
                    .multilineTextAlignment(.leading)
                
                // Descrição
                Text(tip.description)
                    .font(.body)
                    .foregroundColor(DS.ColorSet.textSecondary)
                    .lineLimit(isExpanded ? nil : 3)
                    .multilineTextAlignment(.leading)
                
                if !isExpanded {
                    Spacer(minLength: 8)
                }
            }
            .padding(DS.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: isExpanded ? nil : 120)
            .frame(minHeight: 120)
            .background(Color.white)
            .cornerRadius(DS.Radius.lg)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


