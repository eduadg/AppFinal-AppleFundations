import SwiftUI

public struct TipsCarousel: View {
    let items: [TipItem]
    @State private var selectedTip: TipItem? = nil
    @State private var showingTipModal = false
    
    public init(items: [TipItem]) {
        self.items = items
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: DS.Spacing.md) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, tip in
                    TipsCard(
                        tip: tip,
                        onTap: {
                            selectedTip = tip
                            showingTipModal = true
                        }
                    )
                    .frame(width: 280)
                }
            }
            .padding(.horizontal, DS.Spacing.md)
        }
        .sheet(isPresented: $showingTipModal) {
            if let tip = selectedTip {
                TipDetailModal(tip: tip)
            }
        }
    }
}

struct TipsCard: View {
    let tip: TipItem
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
                    
                    // Indicador para abrir modal
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(DS.ColorSet.textSecondary)
                }
                
                // Título da dica
                Text(tip.title)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(DS.ColorSet.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Descrição truncada
                Text(tip.description)
                    .font(.body)
                    .foregroundColor(DS.ColorSet.textSecondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                Spacer(minLength: 8)
            }
            .padding(DS.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 120)
            .background(Color.white)
            .cornerRadius(DS.Radius.lg)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TipDetailModal: View {
    let tip: TipItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                // Header com ícone
                HStack {
                    Image(systemName: tip.icon)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(DS.ColorSet.brand)
                        .frame(width: 48, height: 48)
                        .background(DS.ColorSet.brandMuted)
                        .cornerRadius(12)
                    
                    Spacer()
                }
                .padding(.top, DS.Spacing.md)
                
                // Título
                Text(tip.title)
                    .font(.title2.weight(.bold))
                    .foregroundColor(DS.ColorSet.textPrimary)
                    .multilineTextAlignment(.leading)
                
                // Descrição completa
                Text(tip.description)
                    .font(.body)
                    .foregroundColor(DS.ColorSet.textSecondary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                
                Spacer()
            }
            .padding(DS.Spacing.lg)
            .navigationTitle("Dica")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                    .foregroundColor(DS.ColorSet.brand)
                }
            }
        }
    }
}
