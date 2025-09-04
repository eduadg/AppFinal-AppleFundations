import SwiftUI

public struct EnciclopediaView: View {
    @StateObject private var encyclopediaData = EncyclopediaDataManager.shared
    @StateObject private var hospitalData = HospitalDataManager.shared
    @State private var searchText = ""
    @State private var selectedCategory: PostCategory?
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
                        
                        // Categories Section
                        if searchText.isEmpty {
                            CategoriesSection(selectedCategory: $selectedCategory)
                        }
                        
                        // Featured Posts (when no search/category)
                        if searchText.isEmpty && selectedCategory == nil {
                            FeaturedPostsSection()
                        }
                        
                        // Posts List
                        PostsListSection(
                            searchText: searchText,
                            selectedCategory: selectedCategory
                        )
                        
                        // Hospital Integration Section
                        if !hospitalData.plantsInTreatment.isEmpty && searchText.isEmpty && selectedCategory == nil {
                            HospitalIntegrationSection()
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, DS.Spacing.sm)
                }
            }
            .navigationTitle("Enciclopédia")
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
            AddPostView()
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
            
            TextField("Buscar posts, plantas, doenças...", text: $text)
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

// MARK: - Categories Section
struct CategoriesSection: View {
    @Binding var selectedCategory: PostCategory?
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack {
                Text("Categorias")
                    .font(.title2.weight(.bold))
                    .foregroundColor(DS.ColorSet.textPrimary)
                
                Spacer()
                
                if selectedCategory != nil {
                    Button("Ver Todas") {
                        selectedCategory = nil
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(DS.ColorSet.brand)
                }
            }
            .padding(.horizontal, DS.Spacing.md)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Spacing.sm) {
                    ForEach(PostCategory.allCases, id: \.self) { category in
                        CategoryCard(
                            category: category,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    }
                }
                .padding(.horizontal, DS.Spacing.md)
            }
        }
    }
}

struct CategoryCard: View {
    let category: PostCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DS.Spacing.sm) {
                Image(systemName: category.iconName)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : Color(category.color))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(isSelected ? Color(category.color) : Color(category.color).opacity(0.1))
                    )
                
                Text(category.rawValue)
                    .font(.caption.weight(.medium))
                    .foregroundColor(isSelected ? DS.ColorSet.brand : DS.ColorSet.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 80)
            .padding(.vertical, DS.Spacing.sm)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Featured Posts Section
struct FeaturedPostsSection: View {
    @EnvironmentObject var encyclopediaData: EncyclopediaDataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack {
                Text("Posts em Destaque")
                    .font(.title2.weight(.bold))
                    .foregroundColor(DS.ColorSet.textPrimary)
                
                Spacer()
                
                Image(systemName: "star.fill")
                    .font(.title3)
                    .foregroundColor(.yellow)
            }
            .padding(.horizontal, DS.Spacing.md)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Spacing.md) {
                    ForEach(encyclopediaData.featuredPosts.prefix(3), id: \.id) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            FeaturedPostCard(post: post)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, DS.Spacing.md)
            }
        }
    }
}

struct FeaturedPostCard: View {
    let post: EncyclopediaPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            // Category badge
            HStack {
                Text(post.category.rawValue)
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(post.category.color))
                    .cornerRadius(8)
                
                Spacer()
                
                Text("\(post.readTime) min")
                    .font(.caption2)
                    .foregroundColor(DS.ColorSet.textSecondary)
            }
            
            Text(post.title)
                .font(.headline.weight(.semibold))
                .foregroundColor(DS.ColorSet.textPrimary)
                .lineLimit(2)
            
            Text(post.summary)
                .font(.subheadline)
                .foregroundColor(DS.ColorSet.textSecondary)
                .lineLimit(3)
            
            HStack {
                Text(post.formattedDate)
                    .font(.caption)
                    .foregroundColor(DS.ColorSet.textSecondary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                    Text("\(post.likes)")
                        .font(.caption)
                        .foregroundColor(DS.ColorSet.textSecondary)
                }
            }
        }
        .padding(DS.Spacing.md)
        .frame(width: 280)
        .background(Color.white)
        .cornerRadius(DS.Radius.lg)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Posts List Section
struct PostsListSection: View {
    let searchText: String
    let selectedCategory: PostCategory?
    @EnvironmentObject var encyclopediaData: EncyclopediaDataManager
    
    private var filteredPosts: [EncyclopediaPost] {
        var posts = encyclopediaData.posts
        
        if !searchText.isEmpty {
            posts = encyclopediaData.searchPosts(searchText)
        }
        
        if let category = selectedCategory {
            posts = posts.filter { $0.category == category }
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
                } else if selectedCategory != nil {
                    Text(selectedCategory!.rawValue)
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
                    icon: "doc.text.magnifyingglass",
                    title: "Nenhum post encontrado",
                    message: searchText.isEmpty ? 
                        "Nenhum post nesta categoria ainda." :
                        "Tente buscar por outros termos."
                )
                .padding(.vertical, DS.Spacing.xl)
            } else {
                LazyVStack(spacing: DS.Spacing.md) {
                    ForEach(filteredPosts, id: \.id) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            PostListCard(post: post)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, DS.Spacing.md)
            }
        }
    }
}

struct PostListCard: View {
    let post: EncyclopediaPost
    
    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            // Category icon
            Image(systemName: post.category.iconName)
                .font(.title2)
                .foregroundColor(Color(post.category.color))
                .frame(width: 40, height: 40)
                .background(Color(post.category.color).opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                HStack {
                    Text(post.category.rawValue)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Color(post.category.color))
                    
                    Spacer()
                    
                    Text("\(post.readTime) min")
                        .font(.caption2)
                        .foregroundColor(DS.ColorSet.textSecondary)
                }
                
                Text(post.title)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(DS.ColorSet.textPrimary)
                    .lineLimit(1)
                
                Text(post.summary)
                    .font(.subheadline)
                    .foregroundColor(DS.ColorSet.textSecondary)
                    .lineLimit(2)
                
                HStack {
                    Text(post.formattedDate)
                        .font(.caption)
                        .foregroundColor(DS.ColorSet.textSecondary)
                    
                    Spacer()
                    
                    if post.isUserGenerated {
                        Image(systemName: "person.fill")
                            .font(.caption)
                            .foregroundColor(DS.ColorSet.brand)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                        Text("\(post.likes)")
                            .font(.caption)
                            .foregroundColor(DS.ColorSet.textSecondary)
                    }
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(DS.ColorSet.textSecondary)
        }
        .padding(DS.Spacing.md)
        .background(Color.white)
        .cornerRadius(DS.Radius.lg)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Hospital Integration Section
struct HospitalIntegrationSection: View {
    @EnvironmentObject var encyclopediaData: EncyclopediaDataManager
    @EnvironmentObject var hospitalData: HospitalDataManager
    
    private var suggestedPosts: [EncyclopediaPost] {
        var suggestions: [EncyclopediaPost] = []
        
        for plant in hospitalData.plantsInTreatment {
            let relatedPosts = encyclopediaData.getPostsRelatedToPlant(plant.name)
            suggestions.append(contentsOf: relatedPosts)
        }
        
        // Remove duplicatas e limita a 3
        return Array(Set(suggestions)).prefix(3).map { $0 }
    }
    
    var body: some View {
        if !suggestedPosts.isEmpty {
            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                HStack {
                    Image(systemName: "cross.case.fill")
                        .font(.title3)
                        .foregroundColor(DS.ColorSet.brand)
                    
                    Text("Relacionado às suas plantas")
                        .font(.title2.weight(.bold))
                        .foregroundColor(DS.ColorSet.textPrimary)
                }
                .padding(.horizontal, DS.Spacing.md)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DS.Spacing.md) {
                        ForEach(suggestedPosts, id: \.id) { post in
                            NavigationLink(destination: PostDetailView(post: post)) {
                                SuggestedPostCard(post: post)
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

struct SuggestedPostCard: View {
    let post: EncyclopediaPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack {
                Image(systemName: post.category.iconName)
                    .font(.title3)
                    .foregroundColor(Color(post.category.color))
                
                Spacer()
                
                Image(systemName: "lightbulb.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
            
            Text(post.title)
                .font(.headline.weight(.semibold))
                .foregroundColor(DS.ColorSet.textPrimary)
                .lineLimit(2)
            
            Text(post.summary)
                .font(.subheadline)
                .foregroundColor(DS.ColorSet.textSecondary)
                .lineLimit(2)
            
            Text("Relacionado às suas plantas")
                .font(.caption.weight(.medium))
                .foregroundColor(DS.ColorSet.brand)
        }
        .padding(DS.Spacing.md)
        .frame(width: 200)
        .background(
            LinearGradient(
                colors: [Color.white, DS.ColorSet.brand.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(DS.Radius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.lg)
                .stroke(DS.ColorSet.brand.opacity(0.2), lineWidth: 1)
        )
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
