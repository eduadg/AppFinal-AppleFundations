import SwiftUI

public struct TipsCarousel: View {
    let items: [TipItem]
    @State private var expandedCardIndex: Int? = nil
    @State private var currentIndex: Int = 0
    @State private var timer: Timer?
    @State private var offset: CGFloat = 0
    
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
                            handleCardTap(index: index)
                        }
                    )
                    .frame(width: expandedCardIndex == index ? 350 : 280)
                }
            }
            .padding(.horizontal, DS.Spacing.md)
            .offset(x: offset)
        }
        .onAppear {
            startAutoScroll()
        }
        .onDisappear {
            stopAutoScroll()
        }
    }
    
    private func handleCardTap(index: Int) {
        stopAutoScroll()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            expandedCardIndex = expandedCardIndex == index ? nil : index
        }
        
        if expandedCardIndex == index {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if expandedCardIndex == nil {
                    startAutoScroll()
                }
            }
        }
    }
    
    private func startAutoScroll() {
        guard expandedCardIndex == nil else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            guard expandedCardIndex == nil else { return }
            
            withAnimation(.easeInOut(duration: 0.8)) {
                currentIndex = (currentIndex + 1) % items.count
                let cardWidth: CGFloat = 280 + DS.Spacing.md
                offset = -CGFloat(currentIndex) * cardWidth
            }
        }
    }
    
    private func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
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
                    .fixedSize(horizontal: false, vertical: true)
                
                // Descrição
                Text(tip.description)
                    .font(.body)
                    .foregroundColor(DS.ColorSet.textSecondary)
                    .lineLimit(isExpanded ? nil : 3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Spacer apenas quando não expandido
                if !isExpanded {
                    Spacer(minLength: 0)
                } else {
                    // Pequeno espaço no final quando expandido
                    Spacer(minLength: 4)
                }
            }
            .padding(DS.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .frame(height: isExpanded ? nil : 120)
            .background(Color.white)
            .cornerRadius(DS.Radius.lg)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
}


