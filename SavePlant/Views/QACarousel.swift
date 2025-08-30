import SwiftUI

public struct QACarousel: View {
    let items: [QAItem]
    @State private var index = 0
    
    public init(items: [QAItem]) {
        self.items = items
        UIPageControl.appearance().backgroundStyle = .prominent
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(DS.ColorSet.brand)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemGray3
    }
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(items) { item in
                    QACard(item: item)
                        .frame(width: UIScreen.main.bounds.width * 0.78)
                }
            }
            .padding(.horizontal, DS.Spacing.xl)
            .padding(.vertical, DS.Spacing.sm)
        }
    }


}

