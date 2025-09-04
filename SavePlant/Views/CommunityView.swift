import SwiftUI

public struct CommunityView: View {
    @StateObject private var communityData = CommunityDataManager()
    @State private var searchText = ""
    @State private var selectedType: PostType?
    @State private var showingAddPost = false
    
    public init() {}
    
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
                        // Search Bar
                        SearchBarView(text: $searchText)
                            .padding(.horizontal, DS.Spacing.md)
                        
                        // Post Types Filter
                        PostTypesFilter(selectedType: $selectedType)
                        
                        // Trending Posts
                        TrendingPostsSection(communityData: communityData)
                        
                        // All Posts
                        AllPostsSection(
                            searchText: searchText,
                            selectedType: selectedType,
                            communityData: communityData
                        )
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, DS.Spacing.sm)
                }
            }
            .navigationTitle("Comunidade")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddPost = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(DS.ColorSet.brand)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddPost) {
            AddCommunityPostView()
        }
    }
}

// MARK: - Search Bar
struct SearchBarView: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(DS.ColorSet.textSecondary)
            
            TextField("Buscar posts, plantas, dicas...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(DS.ColorSet.textSecondary)
                }
            }
        }
        .padding(DS.Spacing.md)
        .background(Color.white)
        .cornerRadius(DS.Radius.lg)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Post Types Filter
struct PostTypesFilter: View {
    @Binding var selectedType: PostType?
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack {
                Text("Filtrar por Tipo")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(DS.ColorSet.textPrimary)
                
                Spacer()
                
                if selectedType != nil {
                    Button("Ver Todos") {
                        selectedType = nil
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(DS.ColorSet.brand)
                }
            }
            .padding(.horizontal, DS.Spacing.md)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Spacing.sm) {
                    ForEach(PostType.allCases, id: \.self) { type in
                        PostTypeCard(
                            type: type,
                            isSelected: selectedType == type
                        ) {
                            selectedType = selectedType == type ? nil : type
                        }
                    }
                }
                .padding(.horizontal, DS.Spacing.md)
            }
        }
    }
}

struct PostTypeCard: View {
    let type: PostType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.xs) {
                Image(systemName: type.iconName)
                    .font(.subheadline)
                    .foregroundColor(isSelected ? .white : Color(type.color))
                
                Text(type.rawValue)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(isSelected ? .white : Color(type.color))
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
            .background(
                isSelected ? Color(type.color) : Color(type.color).opacity(0.1)
            )
            .cornerRadius(DS.Radius.lg)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Trending Posts Section
struct TrendingPostsSection: View {
    @ObservedObject var communityData: CommunityDataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.title3)
                    .foregroundColor(.orange)
                
                Text("Posts em Alta")
                    .font(.title2.weight(.bold))
                    .foregroundColor(DS.ColorSet.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, DS.Spacing.md)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Spacing.md) {
                    ForEach(communityData.trendingPosts, id: \.id) { post in
                        TrendingPostCard(post: post)
                    }
                }
                .padding(.horizontal, DS.Spacing.md)
            }
        }
    }
}

struct TrendingPostCard: View {
    let post: CommunityPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            // Header with user info
            HStack {
                Image(systemName: post.user.avatar)
                    .font(.title3)
                    .foregroundColor(DS.ColorSet.brand)
                    .frame(width: 32, height: 32)
                    .background(DS.ColorSet.brand.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.user.name)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(DS.ColorSet.textPrimary)
                    
                    Text(post.user.location)
                        .font(.caption2)
                        .foregroundColor(DS.ColorSet.textSecondary)
                }
                
                Spacer()
                
                // Post type badge
                Text(post.type.rawValue)
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(post.type.color))
                    .cornerRadius(4)
            }
            
            // Title
            Text(post.title)
                .font(.headline.weight(.semibold))
                .foregroundColor(DS.ColorSet.textPrimary)
                .lineLimit(2)
            
            // Content preview
            Text(post.content)
                .font(.subheadline)
                .foregroundColor(DS.ColorSet.textSecondary)
                .lineLimit(3)
            
            // Plant info if available
            if let plantName = post.plantName {
                HStack {
                    Image(systemName: "leaf.fill")
                        .font(.caption)
                        .foregroundColor(DS.ColorSet.brand)
                    
                    Text(plantName)
                        .font(.caption.weight(.medium))
                        .foregroundColor(DS.ColorSet.textPrimary)
                    
                    if let disease = post.plantDisease {
                        Text("• \(disease)")
                            .font(.caption)
                            .foregroundColor(DS.ColorSet.textSecondary)
                    }
                }
            }
            
            // Stats
            HStack {
                Text(post.formattedDate)
                    .font(.caption)
                    .foregroundColor(DS.ColorSet.textSecondary)
                
                Spacer()
                
                HStack(spacing: DS.Spacing.sm) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                        Text("\(post.likes)")
                            .font(.caption)
                            .foregroundColor(DS.ColorSet.textSecondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "message.fill")
                            .font(.caption)
                            .foregroundColor(DS.ColorSet.brand)
                        Text("\(post.comments)")
                            .font(.caption)
                            .foregroundColor(DS.ColorSet.textSecondary)
                    }
                }
            }
        }
        .padding(DS.Spacing.md)
        .frame(width: 300)
        .background(Color.white)
        .cornerRadius(DS.Radius.lg)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

// MARK: - All Posts Section
struct AllPostsSection: View {
    let searchText: String
    let selectedType: PostType?
    @ObservedObject var communityData: CommunityDataManager
    
    private var filteredPosts: [CommunityPost] {
        var posts = communityData.posts
        
        if !searchText.isEmpty {
            posts = communityData.searchPosts(searchText)
        }
        
        if let type = selectedType {
            posts = posts.filter { $0.type == type }
        }
        
        return posts
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack {
                if !searchText.isEmpty {
                    Text("Resultados da Busca")
                        .font(.title2.weight(.bold))
                        .foregroundColor(DS.ColorSet.textPrimary)
                } else if selectedType != nil {
                    Text(selectedType!.rawValue)
                        .font(.title2.weight(.bold))
                        .foregroundColor(DS.ColorSet.textPrimary)
                } else {
                    Text("Todos os Posts")
                        .font(.title2.weight(.bold))
                        .foregroundColor(DS.ColorSet.textPrimary)
                }
                
                Spacer()
                
                Text("\(filteredPosts.count) posts")
                    .font(.subheadline)
                    .foregroundColor(DS.ColorSet.textSecondary)
            }
            .padding(.horizontal, DS.Spacing.md)
            
            if filteredPosts.isEmpty {
                EmptyStateView(
                    icon: "person.3.fill",
                    title: "Nenhum post encontrado",
                    message: searchText.isEmpty ? 
                        "Nenhum post deste tipo ainda." :
                        "Tente buscar por outros termos."
                )
                .padding(.vertical, DS.Spacing.xl)
            } else {
                LazyVStack(spacing: DS.Spacing.md) {
                    ForEach(filteredPosts, id: \.id) { post in
                        CommunityPostCard(post: post)
                    }
                }
                .padding(.horizontal, DS.Spacing.md)
            }
        }
    }
}

struct CommunityPostCard: View {
    let post: CommunityPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            // Header
            HStack {
                Image(systemName: post.user.avatar)
                    .font(.title2)
                    .foregroundColor(DS.ColorSet.brand)
                    .frame(width: 40, height: 40)
                    .background(DS.ColorSet.brand.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.user.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(DS.ColorSet.textPrimary)
                    
                    HStack(spacing: DS.Spacing.xs) {
                        Text(post.user.location)
                            .font(.caption)
                            .foregroundColor(DS.ColorSet.textSecondary)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(DS.ColorSet.textSecondary)
                        
                        Text(post.formattedDate)
                            .font(.caption)
                            .foregroundColor(DS.ColorSet.textSecondary)
                    }
                }
                
                Spacer()
                
                // Post type badge
                Text(post.type.rawValue)
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(post.type.color))
                    .cornerRadius(6)
            }
            
            // Title
            Text(post.title)
                .font(.headline.weight(.semibold))
                .foregroundColor(DS.ColorSet.textPrimary)
                .lineLimit(nil)
            
            // Content
            Text(post.content)
                .font(.body)
                .foregroundColor(DS.ColorSet.textSecondary)
                .lineLimit(nil)
                .lineSpacing(2)
            
            // Plant info if available
            if let plantName = post.plantName {
                HStack {
                    Image(systemName: "leaf.fill")
                        .font(.subheadline)
                        .foregroundColor(DS.ColorSet.brand)
                    
                    Text(plantName)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(DS.ColorSet.textPrimary)
                    
                    if let disease = post.plantDisease {
                        Text("• \(disease)")
                            .font(.subheadline)
                            .foregroundColor(DS.ColorSet.textSecondary)
                    }
                }
                .padding(.vertical, DS.Spacing.xs)
            }
            
            // Tags
            if !post.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DS.Spacing.xs) {
                        ForEach(post.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption.weight(.medium))
                                .foregroundColor(DS.ColorSet.brand)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(DS.ColorSet.brand.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
            }
            
            // Actions
            HStack {
                Button(action: {
                    // Like action
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .font(.subheadline)
                            .foregroundColor(post.isLiked ? .red : DS.ColorSet.textSecondary)
                        
                        Text("\(post.likes)")
                            .font(.subheadline)
                            .foregroundColor(DS.ColorSet.textSecondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    // Comment action
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "message")
                            .font(.subheadline)
                            .foregroundColor(DS.ColorSet.textSecondary)
                        
                        Text("\(post.comments)")
                            .font(.subheadline)
                            .foregroundColor(DS.ColorSet.textSecondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    // Share action
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.subheadline)
                            .foregroundColor(DS.ColorSet.textSecondary)
                        
                        Text("Compartilhar")
                            .font(.subheadline)
                            .foregroundColor(DS.ColorSet.textSecondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
        }
        .padding(DS.Spacing.md)
        .background(Color.white)
        .cornerRadius(DS.Radius.lg)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: DS.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(DS.ColorSet.textSecondary)
            
            VStack(spacing: DS.Spacing.sm) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(DS.ColorSet.textPrimary)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(DS.ColorSet.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DS.Spacing.lg)
            }
        }
    }
}

// MARK: - Add Community Post View (Placeholder)
struct AddCommunityPostView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: DS.Spacing.lg) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(DS.ColorSet.brand)
                
                Text("Novo Post")
                    .font(.title.weight(.bold))
                    .foregroundColor(DS.ColorSet.textPrimary)
                
                Text("Funcionalidade em desenvolvimento")
                    .font(.body)
                    .foregroundColor(DS.ColorSet.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DS.Spacing.lg)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Novo Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
    }
}
