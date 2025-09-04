import SwiftUI
import PhotosUI

public struct AddPostView: View {
    @StateObject private var encyclopediaData = EncyclopediaDataManager.shared
    @StateObject private var hospitalData = HospitalDataManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var summary = ""
    @State private var content = ""
    @State private var selectedCategory: PostCategory = .curiosidades
    @State private var tags = ""
    @State private var relatedPlants = ""
    @State private var selectedPhoto: UIImage?
    @State private var showingImagePicker = false
    @State private var readTime = 5
    
    // Hospital integration
    @State private var showingPlantPicker = false
    @State private var selectedHospitalPlant: PlantInTreatment?
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var tagsArray: [String] {
        tags.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }
    
    private var relatedPlantsArray: [String] {
        relatedPlants.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }
    
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
                        // Hospital Integration Section
                        if !hospitalData.plantsInTreatment.isEmpty {
                            HospitalIntegrationCard()
                        }
                        
                        // Basic Info Section
                        BasicInfoSection(
                            title: $title,
                            summary: $summary,
                            selectedCategory: $selectedCategory
                        )
                        
                        // Photo Section
                        PhotoSection(
                            selectedPhoto: $selectedPhoto,
                            showingImagePicker: $showingImagePicker
                        )
                        
                        // Content Section
                        ContentSection(
                            content: $content,
                            readTime: $readTime
                        )
                        
                        // Metadata Section
                        MetadataSection(
                            tags: $tags,
                            relatedPlants: $relatedPlants
                        )
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, DS.Spacing.md)
                    .padding(.top, DS.Spacing.sm)
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
                        publishPost()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid)
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedPhoto)
        }
        .sheet(isPresented: $showingPlantPicker) {
            PlantPickerView(selectedPlant: $selectedHospitalPlant) {
                if let plant = selectedHospitalPlant {
                    fillFromPlant(plant)
                }
            }
        }
    }
    
    private func publishPost() {
        let imageData = selectedPhoto?.jpegData(compressionQuality: 0.8)
        
        let newPost = EncyclopediaPost(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            summary: summary.trimmingCharacters(in: .whitespacesAndNewlines),
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory,
            author: "Usuário",
            readTime: readTime,
            tags: tagsArray,
            relatedPlantNames: relatedPlantsArray,
            imageData: imageData,
            isUserGenerated: true
        )
        
        encyclopediaData.addPost(newPost)
        dismiss()
    }
    
    private func fillFromPlant(_ plant: PlantInTreatment) {
        title = "Minha experiência com \(plant.name)"
        summary = "Compartilhando minha experiência no tratamento de \(plant.disease) em \(plant.name)."
        selectedCategory = .tratamentos
        relatedPlants = plant.name
        
        content = """
# Minha Experiência com \(plant.name)

## Situação Inicial
Minha planta \(plant.name) foi diagnosticada com **\(plant.disease)** em \(plant.diagnosisDate.formatted(.dateTime.day().month(.abbreviated).year())).

## Tratamento Aplicado
\(plant.treatment)

## Observações
- Status atual: \(plant.status.rawValue)
- Última atualização: \(plant.lastUpdate.formatted(.dateTime.day().month(.abbreviated).year()))

## Dicas Importantes
[Adicione suas dicas e observações aqui]

## Resultados
[Descreva os resultados obtidos]

---
*Post baseado na minha planta do Hospital SavePlant*
"""
        
        tags = plant.disease.lowercased() + ", " + plant.name.lowercased() + ", experiência, tratamento"
    }
}

// MARK: - Hospital Integration Card
struct HospitalIntegrationCard: View {
    @EnvironmentObject var hospitalData: HospitalDataManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack {
                Image(systemName: "cross.case.fill")
                    .font(.title3)
                    .foregroundColor(DS.ColorSet.brand)
                
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text("Baseado em suas plantas")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(DS.ColorSet.textPrimary)
                    
                    Text("Crie posts sobre suas experiências no hospital")
                        .font(.subheadline)
                        .foregroundColor(DS.ColorSet.textSecondary)
                }
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Spacing.sm) {
                    ForEach(hospitalData.plantsInTreatment.prefix(3), id: \.id) { plant in
                        PlantQuickCard(plant: plant)
                    }
                }
                .padding(.horizontal, DS.Spacing.xs)
            }
        }
        .padding(DS.Spacing.md)
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

struct PlantQuickCard: View {
    let plant: PlantInTreatment
    
    var body: some View {
        Button(action: {
            // Implementar seleção da planta
        }) {
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                HStack {
                    if let photo = plant.latestPhoto {
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "leaf.fill")
                            .font(.title3)
                            .foregroundColor(DS.ColorSet.brand)
                            .frame(width: 30, height: 30)
                            .background(DS.ColorSet.brand.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Image(systemName: "plus.circle.fill")
                        .font(.caption)
                        .foregroundColor(DS.ColorSet.brand)
                }
                
                Text(plant.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(DS.ColorSet.textPrimary)
                    .lineLimit(1)
                
                Text(plant.disease)
                    .font(.caption)
                    .foregroundColor(DS.ColorSet.textSecondary)
                    .lineLimit(1)
                
                Text(plant.status.rawValue)
                    .font(.caption2.weight(.medium))
                    .foregroundColor(Color(plant.status.color))
            }
            .padding(DS.Spacing.sm)
            .frame(width: 120)
            .background(Color.white)
            .cornerRadius(DS.Radius.md)
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Basic Info Section
struct BasicInfoSection: View {
    @Binding var title: String
    @Binding var summary: String
    @Binding var selectedCategory: PostCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Informações Básicas")
                .font(.headline.weight(.semibold))
                .foregroundColor(DS.ColorSet.textPrimary)
            
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                Text("Título *")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(DS.ColorSet.textPrimary)
                
                TextField("Digite o título do post", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.body)
            }
            
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                Text("Resumo *")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(DS.ColorSet.textPrimary)
                
                TextField("Breve descrição do post", text: $summary, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.body)
                    .lineLimit(3...5)
            }
            
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                Text("Categoria *")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(DS.ColorSet.textPrimary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DS.Spacing.sm) {
                        ForEach(PostCategory.allCases, id: \.self) { category in
                            CategorySelectionButton(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal, DS.Spacing.xs)
                }
            }
        }
        .padding(DS.Spacing.md)
        .background(Color.white)
        .cornerRadius(DS.Radius.lg)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

struct CategorySelectionButton: View {
    let category: PostCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.xs) {
                Image(systemName: category.iconName)
                    .font(.subheadline)
                    .foregroundColor(isSelected ? .white : Color(category.color))
                
                Text(category.rawValue)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(isSelected ? .white : Color(category.color))
            }
            .padding(.horizontal, DS.Spacing.sm)
            .padding(.vertical, DS.Spacing.xs)
            .background(
                isSelected ? Color(category.color) : Color(category.color).opacity(0.1)
            )
            .cornerRadius(DS.Radius.sm)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Photo Section
struct PhotoSection: View {
    @Binding var selectedPhoto: UIImage?
    @Binding var showingImagePicker: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Foto (Opcional)")
                .font(.headline.weight(.semibold))
                .foregroundColor(DS.ColorSet.textPrimary)
            
            Button(action: {
                showingImagePicker = true
            }) {
                if let photo = selectedPhoto {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(maxHeight: 200)
                        .clipped()
                        .cornerRadius(DS.Radius.md)
                        .overlay(
                            VStack {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        selectedPhoto = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .background(Color.black.opacity(0.5))
                                            .clipShape(Circle())
                                    }
                                    .padding(DS.Spacing.sm)
                                }
                                Spacer()
                            }
                        )
                } else {
                    VStack(spacing: DS.Spacing.md) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 32))
                            .foregroundColor(DS.ColorSet.textSecondary)
                        
                        Text("Toque para adicionar uma foto")
                            .font(.subheadline)
                            .foregroundColor(DS.ColorSet.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .background(DS.ColorSet.textSecondary.opacity(0.1))
                    .cornerRadius(DS.Radius.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.md)
                            .stroke(DS.ColorSet.textSecondary.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                    )
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(DS.Spacing.md)
        .background(Color.white)
        .cornerRadius(DS.Radius.lg)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Content Section
struct ContentSection: View {
    @Binding var content: String
    @Binding var readTime: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack {
                Text("Conteúdo *")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(DS.ColorSet.textPrimary)
                
                Spacer()
                
                HStack(spacing: DS.Spacing.xs) {
                    Text("Tempo de leitura:")
                        .font(.caption)
                        .foregroundColor(DS.ColorSet.textSecondary)
                    
                    Stepper("\(readTime) min", value: $readTime, in: 1...30)
                        .font(.caption.weight(.medium))
                        .foregroundColor(DS.ColorSet.textPrimary)
                }
            }
            
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                Text("Use Markdown para formatação:")
                    .font(.caption)
                    .foregroundColor(DS.ColorSet.textSecondary)
                
                Text("# Título, ## Subtítulo, **negrito**, - lista")
                    .font(.caption2)
                    .foregroundColor(DS.ColorSet.textSecondary.opacity(0.7))
                
                TextEditor(text: $content)
                    .font(.body)
                    .frame(minHeight: 200)
                    .padding(DS.Spacing.xs)
                    .background(Color(.systemGray6))
                    .cornerRadius(DS.Radius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.sm)
                            .stroke(DS.ColorSet.textSecondary.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding(DS.Spacing.md)
        .background(Color.white)
        .cornerRadius(DS.Radius.lg)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Metadata Section
struct MetadataSection: View {
    @Binding var tags: String
    @Binding var relatedPlants: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Informações Adicionais")
                .font(.headline.weight(.semibold))
                .foregroundColor(DS.ColorSet.textPrimary)
            
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                Text("Tags")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(DS.ColorSet.textPrimary)
                
                TextField("tag1, tag2, tag3", text: $tags)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.body)
                
                Text("Separe as tags com vírgulas")
                    .font(.caption)
                    .foregroundColor(DS.ColorSet.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                Text("Plantas Relacionadas")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(DS.ColorSet.textPrimary)
                
                TextField("tomate, rosa, citrus", text: $relatedPlants)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.body)
                
                Text("Plantas que se relacionam com este post")
                    .font(.caption)
                    .foregroundColor(DS.ColorSet.textSecondary)
            }
        }
        .padding(DS.Spacing.md)
        .background(Color.white)
        .cornerRadius(DS.Radius.lg)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Plant Picker View
struct PlantPickerView: View {
    @Binding var selectedPlant: PlantInTreatment?
    let onSelection: () -> Void
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var hospitalData: HospitalDataManager
    
    var body: some View {
        NavigationView {
            List(hospitalData.plantsInTreatment, id: \.id) { plant in
                Button(action: {
                    selectedPlant = plant
                    onSelection()
                    dismiss()
                }) {
                    HStack(spacing: DS.Spacing.md) {
                        if let photo = plant.latestPhoto {
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            Image(systemName: "leaf.fill")
                                .font(.title2)
                                .foregroundColor(DS.ColorSet.brand)
                                .frame(width: 50, height: 50)
                                .background(DS.ColorSet.brand.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                            Text(plant.name)
                                .font(.headline)
                                .foregroundColor(DS.ColorSet.textPrimary)
                            
                            Text(plant.disease)
                                .font(.subheadline)
                                .foregroundColor(DS.ColorSet.textSecondary)
                            
                            Text(plant.status.rawValue)
                                .font(.caption.weight(.medium))
                                .foregroundColor(Color(plant.status.color))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(DS.ColorSet.textSecondary)
                    }
                    .padding(.vertical, DS.Spacing.xs)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Escolher Planta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }
}
