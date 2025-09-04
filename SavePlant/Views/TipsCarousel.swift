import SwiftUI

public struct TipsCarousel: View {
    let items: [TipItem]
    @State private var offset: CGFloat = 0
    @State private var timer: Timer?
    
    public init(items: [TipItem]) {
        self.items = items
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let cardWidth: CGFloat = 280 + DS.Spacing.md
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Spacing.md) {
                    // Primeira sequência de cards
                    ForEach(Array(items.enumerated()), id: \.offset) { index, tip in
                        TipsCard(tip: tip)
                            .frame(width: 280)
                    }
                    
                    // Segunda sequência (duplicada para rolagem infinita)
                    ForEach(Array(items.enumerated()), id: \.offset) { index, tip in
                        TipsCard(tip: tip)
                            .frame(width: 280)
                    }
                }
                .padding(.horizontal, DS.Spacing.md)
                .offset(x: offset)
            }
            .disabled(true) // Desabilita scroll manual para manter o controle automático
        }
        .frame(height: 140) // Altura fixa para o carrossel
        .onAppear {
            startContinuousScroll()
        }
        .onDisappear {
            stopContinuousScroll()
        }
    }
    
    private func startContinuousScroll() {
        let cardWidth: CGFloat = 280 + DS.Spacing.md
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.033, repeats: true) { _ in // Aumentado em 50% (de 0.05 para 0.033)
            withAnimation(.linear(duration: 0.033)) {
                offset -= 1.5 // Aumentado em 50% (de 1 para 1.5)
                
                // Quando a primeira sequência sair completamente da tela
                if offset <= -cardWidth * CGFloat(items.count) {
                    offset = 0 // Reset para o início sem animação
                }
            }
        }
    }
    
    private func stopContinuousScroll() {
        timer?.invalidate()
        timer = nil
    }
}

struct TipsCard: View {
    let tip: TipItem
    
    var body: some View {
        VStack(alignment: .center, spacing: DS.Spacing.sm) { // Mudado para .center
            // Título da dica
            Text(tip.title)
                .font(.headline.weight(.semibold))
                .foregroundColor(DS.ColorSet.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center) // Mudado para .center
                .fixedSize(horizontal: false, vertical: true)
            
            // Descrição
            Text(tip.description)
                .font(.body)
                .foregroundColor(DS.ColorSet.textSecondary)
                .lineLimit(3)
                .multilineTextAlignment(.center) // Mudado para .center
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 0)
        }
        .padding(DS.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .center) // Mudado para .center
        .frame(height: 120)
        .background(Color.white)
        .cornerRadius(DS.Radius.lg)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}


