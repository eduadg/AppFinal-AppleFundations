import SwiftUI

public struct TipsCarousel: View {
    let items: [TipItem]
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
                    TipsCard(tip: tip)
                        .frame(width: 280)
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
    
    private func startAutoScroll() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            // Título da dica
            Text(tip.title)
                .font(.headline.weight(.semibold))
                .foregroundColor(DS.ColorSet.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            // Descrição
            Text(tip.description)
                .font(.body)
                .foregroundColor(DS.ColorSet.textSecondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
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


