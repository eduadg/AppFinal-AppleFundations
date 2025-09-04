import SwiftUI

public struct PostDetailView: View {
    let post: EncyclopediaPost
    @EnvironmentObject var encyclopediaData: EncyclopediaDataManager
    @Environment(\.dismiss) private var dismiss
    @State private var isLiked = false
    @State private var showingShareSheet = false
    
    public init(post: EncyclopediaPost) {
        self.post = post
    }
    
    public var body: some View {
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
                VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                    // Header Section
                    PostHeaderSection(post: post)
                    
                    // Content Section
                    PostContentSection(post: post)
                    
                    // Tags Section
                    if !post.tags.isEmpty {
                        PostTagsSection(tags: post.tags)
                    }
                    
                    // Related Plants Section
                    if !post.relatedPlantNames.isEmpty {
                        RelatedPlantsSection(plantNames: post.relatedPlantNames)
                    }
                    
                    // Actions Section
                    PostActionsSection(
                        post: post,
                        isLiked: $isLiked,
                        showingShareSheet: $showingShareSheet
                    )
                    
                    // Related Posts Section
                    RelatedPostsSection(currentPost: post)
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, DS.Spacing.md)
                .padding(.top, DS.Spacing.sm)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: DS.Spacing.sm) {
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                            .foregroundColor(DS.ColorSet.textSecondary)
                    }
                    
                    Button(action: {
                        isLiked.toggle()
                        // encyclopediaData.likePost(post) // Implementar depois
                    }) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundColor(isLiked ? .red : DS.ColorSet.textSecondary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [createShareContent()])
        }
    }
    
    private func createShareContent() -> String {
        return """
        📚 \(post.title)
        
        \(post.summary)
        
        Categoria: \(post.category.rawValue)
        Tempo de leitura: \(post.readTime) minutos
        
        Compartilhado do SavePlant 🌱
        """
    }
}

// MARK: - Post Header Section
struct PostHeaderSection: View {
    let post: EncyclopediaPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            // Category and read time
            HStack {
                HStack(spacing: DS.Spacing.xs) {
                    Image(systemName: post.category.iconName)
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Text(post.category.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, DS.Spacing.sm)
                .padding(.vertical, DS.Spacing.xs)
                .background(Color(post.category.color))
                .cornerRadius(DS.Radius.sm)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(DS.ColorSet.textSecondary)
                    
                    Text("\(post.readTime) min de leitura")
                        .font(.caption)
                        .foregroundColor(DS.ColorSet.textSecondary)
                }
            }
            
            // Title
            Text(post.title)
                .font(.largeTitle.weight(.bold))
                .foregroundColor(DS.ColorSet.textPrimary)
                .lineLimit(nil)
            
            // Summary
            Text(post.summary)
                .font(.title3)
                .foregroundColor(DS.ColorSet.textSecondary)
                .lineLimit(nil)
            
            // Author and date
            HStack {
                HStack(spacing: DS.Spacing.xs) {
                    Image(systemName: post.isUserGenerated ? "person.fill" : "leaf.fill")
                        .font(.caption)
                        .foregroundColor(DS.ColorSet.brand)
                    
                    Text(post.author)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(DS.ColorSet.textPrimary)
                }
                
                Spacer()
                
                Text(post.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(DS.ColorSet.textSecondary)
            }
            
            Divider()
                .background(DS.ColorSet.textSecondary.opacity(0.3))
        }
        .padding(DS.Spacing.md)
        .background(Color.white)
        .cornerRadius(DS.Radius.lg)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Post Content Section
struct PostContentSection: View {
    let post: EncyclopediaPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.lg) {
            // Image if available
            if let image = post.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxHeight: 200)
                    .clipped()
                    .cornerRadius(DS.Radius.md)
            }
            
            // Content
            MarkdownContentView(content: post.content)
        }
        .padding(DS.Spacing.md)
        .background(Color.white)
        .cornerRadius(DS.Radius.lg)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Markdown Content View
struct MarkdownContentView: View {
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            ForEach(parseMarkdown(content), id: \.id) { element in
                switch element.type {
                case .header1:
                    Text(element.text)
                        .font(.title.weight(.bold))
                        .foregroundColor(DS.ColorSet.textPrimary)
                        .padding(.top, DS.Spacing.md)
                        
                case .header2:
                    Text(element.text)
                        .font(.title2.weight(.semibold))
                        .foregroundColor(DS.ColorSet.textPrimary)
                        .padding(.top, DS.Spacing.sm)
                        
                case .header3:
                    Text(element.text)
                        .font(.title3.weight(.medium))
                        .foregroundColor(DS.ColorSet.textPrimary)
                        
                case .paragraph:
                    Text(element.text)
                        .font(.body)
                        .foregroundColor(DS.ColorSet.textSecondary)
                        .lineSpacing(4)
                        
                case .bulletPoint:
                    HStack(alignment: .top, spacing: DS.Spacing.xs) {
                        Text("•")
                            .font(.body.weight(.bold))
                            .foregroundColor(DS.ColorSet.brand)
                        
                        Text(element.text)
                            .font(.body)
                            .foregroundColor(DS.ColorSet.textSecondary)
                            .lineSpacing(2)
                    }
                    .padding(.leading, DS.Spacing.sm)
                    
                case .bold:
                    Text(element.text)
                        .font(.body.weight(.semibold))
                        .foregroundColor(DS.ColorSet.textPrimary)
                        
                case .divider:
                    Divider()
                        .background(DS.ColorSet.textSecondary.opacity(0.3))
                        .padding(.vertical, DS.Spacing.xs)
                }
            }
        }
    }
}

// MARK: - Markdown Parser
enum MarkdownElementType {
    case header1, header2, header3, paragraph, bulletPoint, bold, divider
}

struct MarkdownElement {
    let id = UUID()
    let type: MarkdownElementType
    let text: String
}

func parseMarkdown(_ content: String) -> [MarkdownElement] {
    let lines = content.components(separatedBy: .newlines)
    var elements: [MarkdownElement] = []
    
    for line in lines {
        let trimmedLine = line.trimmingCharacters(in: .whitespaces)
        
        if trimmedLine.isEmpty {
            continue
        } else if trimmedLine.hasPrefix("## ") {
            elements.append(MarkdownElement(type: .header2, text: String(trimmedLine.dropFirst(3))))
        } else if trimmedLine.hasPrefix("### ") {
            elements.append(MarkdownElement(type: .header3, text: String(trimmedLine.dropFirst(4))))
        } else if trimmedLine.hasPrefix("# ") {
            elements.append(MarkdownElement(type: .header1, text: String(trimmedLine.dropFirst(2))))
        } else if trimmedLine.hasPrefix("- ") {
            elements.append(MarkdownElement(type: .bulletPoint, text: String(trimmedLine.dropFirst(2))))
        } else if trimmedLine.hasPrefix("**") && trimmedLine.hasSuffix("**") && trimmedLine.count > 4 {
            let text = String(trimmedLine.dropFirst(2).dropLast(2))
            elements.append(MarkdownElement(type: .bold, text: text))
        } else if trimmedLine == "---" {
            elements.append(MarkdownElement(type: .divider, text: ""))
        } else {
            elements.append(MarkdownElement(type: .paragraph, text: trimmedLine))
        }
    }
    
    return elements
}

// MARK: - Post Tags Section
struct PostTagsSection: View {
    let tags: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack {
                Image(systemName: "tag.fill")
                    .font(.subheadline)
                    .foregroundColor(DS.ColorSet.brand)
                
                Text("Tags")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(DS.ColorSet.textPrimary)
            }
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 100), spacing: DS.Spacing.xs)
            ], spacing: DS.Spacing.xs) {
                ForEach(tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption.weight(.medium))
                        .foregroundColor(DS.ColorSet.brand)
                        .padding(.horizontal, DS.Spacing.sm)
                        .padding(.vertical, DS.Spacing.xs)
                        .background(DS.ColorSet.brand.opacity(0.1))
                        .cornerRadius(DS.Radius.sm)
                }
            }
        }
        .padding(DS.Spacing.md)
        .background(Color.white)
        .cornerRadius(DS.Radius.lg)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Related Plants Section
struct RelatedPlantsSection: View {
    let plantNames: [String]
    @EnvironmentObject var hospitalData: HospitalDataManager
    
    private var hospitalPlants: [PlantInTreatment] {
        hospitalData.plantsInTreatment.filter { plant in
            plantNames.contains { relatedPlant in
                plant.name.lowercased().contains(relatedPlant.lowercased()) ||
                relatedPlant.lowercased().contains(plant.name.lowercased())
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack {
                Image(systemName: "leaf.fill")
                    .font(.subheadline)
                    .foregroundColor(DS.ColorSet.brand)
                
                Text("Plantas Relacionadas")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(DS.ColorSet.textPrimary)
            }
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 120), spacing: DS.Spacing.sm)
            ], spacing: DS.Spacing.sm) {
                ForEach(plantNames, id: \.self) { plantName in
                    PlantTagView(
                        plantName: plantName,
                        isInHospital: hospitalPlants.contains { $0.name.lowercased().contains(plantName.lowercased()) }
                    )
                }
            }
            
            if !hospitalPlants.isEmpty {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text("Suas plantas relacionadas:")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(DS.ColorSet.brand)
                    
                    ForEach(hospitalPlants, id: \.id) { plant in
                        NavigationLink(destination: PlantDetailView(plant: plant)) {
                            HStack(spacing: DS.Spacing.xs) {
                                Image(systemName: "cross.case.fill")
                                    .font(.caption)
                                    .foregroundColor(DS.ColorSet.brand)
                                
                                Text(plant.name)
                                    .font(.caption)
                                    .foregroundColor(DS.ColorSet.textPrimary)
                                
                                Text("(\(plant.disease))")
                                    .font(.caption)
                                    .foregroundColor(DS.ColorSet.textSecondary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundColor(DS.ColorSet.textSecondary)
                            }
                            .padding(.vertical, DS.Spacing.xs)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.top, DS.Spacing.sm)
            }
        }
        .padding(DS.Spacing.md)
        .background(Color.white)
        .cornerRadius(DS.Radius.lg)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

struct PlantTagView: View {
    let plantName: String
    let isInHospital: Bool
    
    var body: some View {
        HStack(spacing: DS.Spacing.xs) {
            if isInHospital {
                Image(systemName: "cross.case.fill")
                    .font(.caption2)
                    .foregroundColor(DS.ColorSet.brand)
            }
            
            Text(plantName.capitalized)
                .font(.caption.weight(.medium))
                .foregroundColor(isInHospital ? DS.ColorSet.brand : DS.ColorSet.textSecondary)
        }
        .padding(.horizontal, DS.Spacing.sm)
        .padding(.vertical, DS.Spacing.xs)
        .background(
            isInHospital ? 
                DS.ColorSet.brand.opacity(0.15) : 
                DS.ColorSet.textSecondary.opacity(0.1)
        )
        .cornerRadius(DS.Radius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.sm)
                .stroke(
                    isInHospital ? DS.ColorSet.brand.opacity(0.3) : Color.clear,
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Post Actions Section
struct PostActionsSection: View {
    let post: EncyclopediaPost
    @Binding var isLiked: Bool
    @Binding var showingShareSheet: Bool
    
    var body: some View {
        HStack(spacing: DS.Spacing.lg) {
            // Like button
            Button(action: {
                isLiked.toggle()
            }) {
                HStack(spacing: DS.Spacing.xs) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundColor(isLiked ? .red : DS.ColorSet.textSecondary)
                    
                    Text("\(post.likes + (isLiked ? 1 : 0))")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(DS.ColorSet.textPrimary)
                }
                .padding(DS.Spacing.md)
                .background(Color.white)
                .cornerRadius(DS.Radius.md)
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Share button
            Button(action: {
                showingShareSheet = true
            }) {
                HStack(spacing: DS.Spacing.xs) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                        .foregroundColor(DS.ColorSet.textSecondary)
                    
                    Text("Compartilhar")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(DS.ColorSet.textPrimary)
                }
                .padding(DS.Spacing.md)
                .background(Color.white)
                .cornerRadius(DS.Radius.md)
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
    }
}

// MARK: - Related Posts Section
struct RelatedPostsSection: View {
    let currentPost: EncyclopediaPost
    @EnvironmentObject var encyclopediaData: EncyclopediaDataManager
    
    private var relatedPosts: [EncyclopediaPost] {
        encyclopediaData.posts
            .filter { $0.id != currentPost.id }
            .filter { $0.category == currentPost.category }
            .prefix(3)
            .map { $0 }
    }
    
    var body: some View {
        if !relatedPosts.isEmpty {
            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .font(.subheadline)
                        .foregroundColor(DS.ColorSet.brand)
                    
                    Text("Posts Relacionados")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(DS.ColorSet.textPrimary)
                }
                .padding(.horizontal, DS.Spacing.md)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DS.Spacing.md) {
                        ForEach(relatedPosts, id: \.id) { post in
                            NavigationLink(destination: PostDetailView(post: post)) {
                                RelatedPostCard(post: post)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, DS.Spacing.md)
                }
            }
        }
    }
}

struct RelatedPostCard: View {
    let post: EncyclopediaPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack {
                Text(post.category.rawValue)
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color(post.category.color))
                    .cornerRadius(6)
                
                Spacer()
                
                Text("\(post.readTime) min")
                    .font(.caption2)
                    .foregroundColor(DS.ColorSet.textSecondary)
            }
            
            Text(post.title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(DS.ColorSet.textPrimary)
                .lineLimit(2)
            
            Text(post.summary)
                .font(.caption)
                .foregroundColor(DS.ColorSet.textSecondary)
                .lineLimit(3)
        }
        .padding(DS.Spacing.sm)
        .frame(width: 180)
        .background(Color.white)
        .cornerRadius(DS.Radius.md)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
