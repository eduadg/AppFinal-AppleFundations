import SwiftUI

public struct EnciclopediaView: View {
    @StateObject private var enciclopediaData = EnciclopediaDataManager.shared
    @State private var showingAddPost = false
    @State private var selectedPost: EnciclopediaPost?
    
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
                
                VStack(spacing: 0) {
                    // Search Bar
                    VStack(spacing: DS.Spacing.sm) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(DS.ColorSet.textSecondary)
                            
                            TextField("Buscar posts...", text: $enciclopediaData.searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .onChange(of: enciclopediaData.searchText) { _, _ in
                                    enciclopediaData.filterPosts()
                                }
                            
                            if !enciclopediaData.searchText.isEmpty {
                                Button(action: {
                                    enciclopediaData.searchText = ""
                                    enciclopediaData.filterPosts()
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(DS.ColorSet.textSecondary)
                                }
                            }
                        }
                        .padding(.horizontal, DS.Spacing.md)
                        .padding(.vertical, DS.Spacing.sm)
                        .background(Color.white)
                        .cornerRadius(DS.Radius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: DS.Radius.md)
                                .stroke(DS.ColorSet.brand.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal, DS.Spacing.md)
                        
                        // Category Filter
                        CategoryFilterView(
                            selectedCategory: $enciclopediaData.selectedCategory,
                            onCategorySelected: { _ in
                                enciclopediaData.filterPosts()
                            }
                        )
                    }
                    .padding(.top, DS.Spacing.sm)
                    
                    // Posts List
                    if enciclopediaData.filteredPosts.isEmpty {
                        // Empty State
                        VStack(spacing: DS.Spacing.lg) {
                            Spacer()
                            
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 64))
                                .foregroundColor(DS.ColorSet.textSecondary)
                            
                            VStack(spacing: DS.Spacing.sm) {
                                Text("Nenhum post encontrado")
                                    .font(.title2.weight(.semibold))
                                    .foregroundColor(DS.ColorSet.textPrimary)
                                
                                Text("Tente ajustar os filtros ou adicione um novo post")
                                    .font(.body)
                                    .foregroundColor(DS.ColorSet.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, DS.Spacing.xl)
                                
                                // Botão de teste temporário
                                Button(action: {
                                    print("🔍 Teste - Total de posts: \(enciclopediaData.posts.count)")
                                    print("🔍 Teste - Posts filtrados: \(enciclopediaData.filteredPosts.count)")
                                    enciclopediaData.filterPosts()
                                    print("✅ Teste - Após filtros: \(enciclopediaData.filteredPosts.count)")
                                }) {
                                    Text("🔍 Testar Dados")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.blue)
                                        .cornerRadius(8)
                                }
                            }
                            
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: DS.Spacing.md) {
                                ForEach(enciclopediaData.filteredPosts) { post in
                                    EnciclopediaPostCard(
                                        post: post,
                                        onLike: {
                                            enciclopediaData.likePost(post.id)
                                        },
                                        onTap: {
                                            selectedPost = post
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, DS.Spacing.md)
                            .padding(.vertical, DS.Spacing.md)
                        }
                    }
                }
            }
            .navigationTitle("Enciclopédia")
            .navigationBarTitleDisplayMode(.large)
            .overlay(
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingAddPost = true
                        }) {
                            HStack(spacing: DS.Spacing.xs) {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Novo Post")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, DS.Spacing.md)
                            .padding(.vertical, DS.Spacing.sm)
                            .background(DS.ColorSet.brand)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, DS.Spacing.lg)
                        .padding(.bottom, DS.Spacing.lg)
                    }
                }
            )
        }
        .sheet(isPresented: $showingAddPost) {
            AddPostView()
        }
        .sheet(item: $selectedPost) { post in
            PostDetailView(post: post)
        }
        .onAppear {
            print("🔍 EnciclopediaView apareceu")
            print("📊 Total de posts: \(enciclopediaData.posts.count)")
            print("🔍 Posts filtrados: \(enciclopediaData.filteredPosts.count)")
            
            // Força recarregamento dos dados
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                enciclopediaData.filterPosts()
                print("✅ Filtros aplicados - Posts filtrados: \(enciclopediaData.filteredPosts.count)")
            }
        }
    }
}

// MARK: - Preview
struct EnciclopediaView_Previews: PreviewProvider {
    static var previews: some View {
        EnciclopediaView()
    }
}
