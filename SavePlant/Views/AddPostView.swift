import SwiftUI

public struct AddPostView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var enciclopediaData = EnciclopediaDataManager.shared
    @StateObject private var hospitalData = HospitalDataManager.shared
    
    @State private var title = ""
    @State private var content = ""
    @State private var author = ""
    @State private var selectedCategory: PostCategory = .dicas
    @State private var tags = ""
    @State private var selectedPlantIds: Set<UUID> = []
    @State private var showingPlantSelector = false
    
    public init() {}
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
                        // Title Section
                        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                            Text("Título do Post")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(DS.ColorSet.textPrimary)
                            
                            TextField("Digite o título do seu post...", text: $title)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.body)
                        }
                        .padding(.horizontal, DS.Spacing.md)
                        
                        // Category Section
                        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                            Text("Categoria")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(DS.ColorSet.textPrimary)
                            
                            Picker("Categoria", selection: $selectedCategory) {
                                ForEach(PostCategory.allCases, id: \.self) { category in
                                    HStack {
                                        Image(systemName: category.icon)
                                            .foregroundColor(category.color)
                                        Text(category.rawValue)
                                    }
                                    .tag(category)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color.white)
                            .cornerRadius(DS.Radius.md)
                            .overlay(
                                RoundedRectangle(cornerRadius: DS.Radius.md)
                                    .stroke(DS.ColorSet.brand.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, DS.Spacing.md)
                        
                        // Content Section
                        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                            Text("Conteúdo")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(DS.ColorSet.textPrimary)
                            
                            TextEditor(text: $content)
                                .frame(minHeight: 200)
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(DS.Radius.md)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DS.Radius.md)
                                        .stroke(DS.ColorSet.brand.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, DS.Spacing.md)
                        
                        // Author Section
                        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                            Text("Autor")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(DS.ColorSet.textPrimary)
                            
                            TextField("Seu nome ou pseudônimo", text: $author)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.body)
                        }
                        .padding(.horizontal, DS.Spacing.md)
                        
                        // Tags Section
                        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                            Text("Tags (separadas por vírgula)")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(DS.ColorSet.textPrimary)
                            
                            TextField("Ex: tomate, doença, tratamento...", text: $tags)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.body)
                        }
                        .padding(.horizontal, DS.Spacing.md)
                        
                        // Related Plants Section
                        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                            Text("Plantas Relacionadas (opcional)")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(DS.ColorSet.textPrimary)
                            
                            Button(action: {
                                showingPlantSelector = true
                            }) {
                                HStack {
                                    Image(systemName: "leaf.fill")
                                        .foregroundColor(DS.ColorSet.brand)
                                    Text(selectedPlantIds.isEmpty ? "Selecionar plantas do hospital" : "\(selectedPlantIds.count) planta(s) selecionada(s)")
                                        .foregroundColor(DS.ColorSet.textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(DS.ColorSet.textSecondary)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(DS.Radius.md)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DS.Radius.md)
                                        .stroke(DS.ColorSet.brand.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if !selectedPlantIds.isEmpty {
                                Text("Seu post será vinculado às plantas selecionadas")
                                    .font(.caption)
                                    .foregroundColor(DS.ColorSet.textSecondary)
                            }
                        }
                        .padding(.horizontal, DS.Spacing.md)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, DS.Spacing.md)
                }
            }
            .navigationTitle("Novo Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(DS.ColorSet.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Publicar") {
                        savePost()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid)
                }
            }
        }
        .sheet(isPresented: $showingPlantSelector) {
            PlantSelectorView(selectedPlantIds: $selectedPlantIds)
        }
    }
    
    private func savePost() {
        let tagArray = tags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let newPost = EnciclopediaPost(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
            author: author.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory,
            tags: tagArray,
            relatedPlantIds: Array(selectedPlantIds)
        )
        
        enciclopediaData.addPost(newPost)
        dismiss()
    }
}

// MARK: - Plant Selector View
struct PlantSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedPlantIds: Set<UUID>
    @StateObject private var hospitalData = HospitalDataManager.shared
    
    var body: some View {
        NavigationView {
            VStack {
                if hospitalData.plantsInTreatment.isEmpty {
                    VStack(spacing: DS.Spacing.lg) {
                        Spacer()
                        
                        Image(systemName: "leaf")
                            .font(.system(size: 64))
                            .foregroundColor(DS.ColorSet.textSecondary)
                        
                        Text("Nenhuma planta no hospital")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(DS.ColorSet.textPrimary)
                        
                        Text("Adicione plantas na seção Hospital para poder vinculá-las aos posts")
                            .font(.body)
                            .foregroundColor(DS.ColorSet.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, DS.Spacing.xl)
                        
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(hospitalData.plantsInTreatment) { plant in
                            Button(action: {
                                if selectedPlantIds.contains(plant.id) {
                                    selectedPlantIds.remove(plant.id)
                                } else {
                                    selectedPlantIds.insert(plant.id)
                                }
                            }) {
                                HStack {
                                    if let photo = plant.latestPhoto {
                                        Image(uiImage: photo)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    } else {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(.systemGray5))
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Image(systemName: "photo")
                                                    .foregroundColor(Color.secondary)
                                            )
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(plant.name)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundColor(DS.ColorSet.textPrimary)
                                        Text(plant.disease)
                                            .font(.caption)
                                            .foregroundColor(DS.ColorSet.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedPlantIds.contains(plant.id) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(DS.ColorSet.brand)
                                            .font(.title2)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .navigationTitle("Selecionar Plantas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Concluir") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Preview
struct AddPostView_Previews: PreviewProvider {
    static var previews: some View {
        AddPostView()
    }
}
