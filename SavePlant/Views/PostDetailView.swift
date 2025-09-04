import SwiftUI

public struct PostDetailView: View {
    let post: EnciclopediaPost
    @StateObject private var enciclopediaData = EnciclopediaDataManager.shared
    @StateObject private var hospitalData = HospitalDataManager.shared
    @Environment(\.dismiss) private var dismiss
    
    public init(post: EnciclopediaPost) {
        self.post = post
    }
    
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
                
                ScrollView {
                    VStack(spacing: DS.Spacing.lg) {
                        // Header Card
                        VStack(alignment: .leading, spacing: DS.Spacing.md) {
                            // Category and Featured Badge
                            HStack {
                                HStack(spacing: DS.Spacing.xs) {
                                    Image(systemName: post.category.icon)
                                        .font(.title3)
                                        .foregroundColor(post.category.color)
                                    Text(post.category.rawValue)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(post.category.color)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(post.category.color.opacity(0.1))
                                .cornerRadius(20)
                                
                                Spacer()
                                
                                if post.isFeatured {
                                    HStack(spacing: DS.Spacing.xs) {
                                        Image(systemName: "star.fill")
                                            .font(.caption)
                                            .foregroundColor(.yellow)
                                        Text("DESTAQUE")
                                            .font(.caption2.weight(.bold))
                                            .foregroundColor(.yellow)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.yellow.opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }
                            
                            // Title
                            Text(post.title)
                                .font(.title.weight(.bold))
                                .foregroundColor(DS.ColorSet.textPrimary)
                                .multilineTextAlignment(.leading)
                            
                            // Author and Date
                            HStack(spacing: DS.Spacing.sm) {
                                Image(systemName: "person.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(DS.ColorSet.brand)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("por \(post.author)")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(DS.ColorSet.textPrimary)
                                    
                                    Text(post.date.formatted(.dateTime.day().month(.abbreviated).year().hour().minute()))
                                        .font(.caption)
                                        .foregroundColor(DS.ColorSet.textSecondary)
                                }
                                
                                Spacer()
                                
                                // Like Button
                                Button(action: {
                                    enciclopediaData.likePost(post.id)
                                }) {
                                    HStack(spacing: DS.Spacing.xs) {
                                        Image(systemName: "heart.fill")
                                            .font(.title3)
                                            .foregroundColor(.red)
                                        Text("\(post.likes)")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundColor(.red)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(20)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(DS.Spacing.md)
                        .background(Color.white)
                        .cornerRadius(DS.Radius.lg)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                        
                        // Content Card
                        VStack(alignment: .leading, spacing: DS.Spacing.md) {
                            Text("Conteúdo")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(DS.ColorSet.textPrimary)
                            
                            Text(post.content)
                                .font(.body)
                                .foregroundColor(DS.ColorSet.textPrimary)
                                .lineSpacing(4)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(DS.Spacing.md)
                        .background(Color.white)
                        .cornerRadius(DS.Radius.lg)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                        
                        // Tags Card
                        if !post.tags.isEmpty {
                            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                                Text("Tags")
                                    .font(.headline.weight(.semibold))
                                    .foregroundColor(DS.ColorSet.textPrimary)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: DS.Spacing.sm) {
                                    ForEach(post.tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption.weight(.medium))
                                            .foregroundColor(DS.ColorSet.brand)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(DS.ColorSet.brand.opacity(0.1))
                                            .cornerRadius(16)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                            .padding(DS.Spacing.md)
                            .background(Color.white)
                            .cornerRadius(DS.Radius.lg)
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                        }
                        
                        // Related Plants Card
                        if !post.relatedPlantIds.isEmpty {
                            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                                Text("Plantas Relacionadas")
                                    .font(.headline.weight(.semibold))
                                    .foregroundColor(DS.ColorSet.textPrimary)
                                
                                LazyVStack(spacing: DS.Spacing.sm) {
                                    ForEach(post.relatedPlantIds, id: \.self) { plantId in
                                        if let plant = hospitalData.plantsInTreatment.first(where: { $0.id == plantId }) {
                                            RelatedPlantRow(plant: plant)
                                        }
                                    }
                                }
                            }
                            .padding(DS.Spacing.md)
                            .background(Color.white)
                            .cornerRadius(DS.Radius.lg)
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, DS.Spacing.md)
                    .padding(.top, DS.Spacing.md)
                }
            }
            .navigationTitle("Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                    .foregroundColor(DS.ColorSet.textSecondary)
                }
            }
        }
    }
}

// MARK: - Related Plant Row
struct RelatedPlantRow: View {
    let plant: PlantInTreatment
    
    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            if let photo = plant.latestPhoto {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.secondary)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(plant.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(DS.ColorSet.textPrimary)
                
                Text(plant.disease)
                    .font(.caption)
                    .foregroundColor(DS.ColorSet.textSecondary)
                
                                                    HStack(spacing: DS.Spacing.xs) {
                                        Circle()
                                            .fill(Color(plant.status.color))
                                            .frame(width: 8, height: 8)
                                        
                                        Text(plant.status.rawValue)
                                            .font(.caption2)
                                            .foregroundColor(Color(plant.status.color))
                                    }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(DS.ColorSet.textSecondary)
        }
        .padding(DS.Spacing.sm)
        .background(DS.ColorSet.brand.opacity(0.05))
        .cornerRadius(DS.Radius.md)
    }
}

// MARK: - Preview
struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PostDetailView(
            post: EnciclopediaPost(
                title: "Como Identificar Doenças por Sintomas Visuais",
                content: "A identificação precoce de doenças é crucial para o sucesso do tratamento. Aqui está um guia visual para ajudar você a identificar problemas comuns nas suas plantas.",
                author: "Dra. Diagnóstico Verde",
                category: .identificacao,
                tags: ["identificação", "sintomas", "diagnóstico"],
                likes: 156,
                isFeatured: true
            )
        )
    }
}
