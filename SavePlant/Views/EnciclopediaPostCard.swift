import SwiftUI

public struct EnciclopediaPostCard: View {
    let post: EnciclopediaPost
    let onLike: () -> Void
    let onTap: () -> Void
    
    public init(post: EnciclopediaPost, onLike: @escaping () -> Void, onTap: @escaping () -> Void) {
        self.post = post
        self.onLike = onLike
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                // Header
                HStack(alignment: .top, spacing: DS.Spacing.sm) {
                    // Category Icon
                    Image(systemName: post.category.icon)
                        .font(.title2)
                        .foregroundColor(post.category.color)
                        .frame(width: 32, height: 32)
                        .background(post.category.color.opacity(0.1))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        // Title
                        Text(post.title)
                            .font(.headline.weight(.semibold))
                            .foregroundColor(DS.ColorSet.textPrimary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        // Author and Date
                        HStack(spacing: DS.Spacing.sm) {
                            Text("por \(post.author)")
                                .font(.caption.weight(.medium))
                                .foregroundColor(DS.ColorSet.textSecondary)
                            
                            Text("•")
                                .font(.caption)
                                .foregroundColor(DS.ColorSet.textSecondary)
                            
                            Text(post.date.formatted(.dateTime.day().month(.abbreviated)))
                                .font(.caption)
                                .foregroundColor(DS.ColorSet.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Featured Badge
                    if post.isFeatured {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                            .padding(4)
                            .background(Color.yellow.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                
                // Content Preview
                Text(post.content)
                    .font(.subheadline)
                    .foregroundColor(DS.ColorSet.textSecondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                // Tags
                if !post.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DS.Spacing.xs) {
                            ForEach(post.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2.weight(.medium))
                                    .foregroundColor(DS.ColorSet.brand)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(DS.ColorSet.brand.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                
                // Footer
                HStack {
                    // Category
                    HStack(spacing: DS.Spacing.xs) {
                        Image(systemName: post.category.icon)
                            .font(.caption)
                            .foregroundColor(post.category.color)
                        Text(post.category.rawValue)
                            .font(.caption.weight(.medium))
                            .foregroundColor(post.category.color)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(post.category.color.opacity(0.1))
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    // Like Button
                    Button(action: onLike) {
                        HStack(spacing: DS.Spacing.xs) {
                            Image(systemName: "heart.fill")
                                .font(.caption)
                                .foregroundColor(.red)
                            Text("\(post.likes)")
                                .font(.caption.weight(.medium))
                                .foregroundColor(DS.ColorSet.textSecondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(DS.Spacing.md)
            .background(Color.white)
            .cornerRadius(DS.Radius.lg)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct EnciclopediaPostCard_Previews: PreviewProvider {
    static var previews: some View {
        EnciclopediaPostCard(
            post: EnciclopediaPost(
                title: "Como Identificar Doenças por Sintomas Visuais",
                content: "A identificação precoce de doenças é crucial para o sucesso do tratamento. Aqui está um guia visual para ajudar você a identificar problemas comuns nas suas plantas.",
                author: "Dra. Diagnóstico Verde",
                category: .identificacao,
                tags: ["identificação", "sintomas", "diagnóstico"],
                likes: 156,
                isFeatured: true
            ),
            onLike: {},
            onTap: {}
        )
        .padding()
        .background(Color(.systemGray6))
    }
}
