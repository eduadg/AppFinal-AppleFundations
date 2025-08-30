import SwiftUI

public struct QACard: View {
    let item: QAItem
    public init(item: QAItem) { self.item = item }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text(item.title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(DS.ColorSet.textPrimary)
                .lineLimit(2)

            HStack {
                HStack(spacing: -8) {
                    ForEach(item.avatars.prefix(4), id: \.self) { name in
                        ZStack {
                            Circle().fill(DS.ColorSet.brandMuted)
                            Image(systemName: name)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(DS.ColorSet.brand)
                        }
                        .frame(width: 22, height: 22)
                        .overlay(Circle().stroke(.white, lineWidth: 1))
                    }
                }
                Spacer()
                Label("\(item.answers) Answers", systemImage: "message.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(DS.ColorSet.brand)
            }
        }
        .padding(DS.Spacing.md)
        .background(.white)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color(.systemGray4).opacity(0.6), lineWidth: 0.6)
        )
        .cornerRadius(16)
        .shadow(color: DS.Shadow.soft, radius: 12, x: 0, y: 6)
        .frame(width: 300)
    }
}

