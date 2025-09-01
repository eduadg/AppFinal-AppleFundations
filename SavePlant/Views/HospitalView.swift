import SwiftUI

public struct HospitalView: View {
    @StateObject private var hospitalData = HospitalDataManager.shared
    @State private var showingAddPlant = false
    
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
                    if hospitalData.plantsInTreatment.isEmpty {
                        // Empty State
                        VStack(spacing: DS.Spacing.lg) {
                            Spacer()
                            
                            Image(systemName: "cross.case")
                                .font(.system(size: 64))
                                .foregroundColor(DS.ColorSet.textSecondary)
                            
                            VStack(spacing: DS.Spacing.sm) {
                                Text("Nenhuma planta em tratamento")
                                    .font(.title2.weight(.semibold))
                                    .foregroundColor(DS.ColorSet.textPrimary)
                                
                                Text("Quando você diagnosticar uma planta doente, ela aparecerá aqui para acompanhamento")
                                    .font(.body)
                                    .foregroundColor(DS.ColorSet.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, DS.Spacing.xl)
                            }
                            
                            Spacer()
                        }
                    } else {
                        // Plants List
                        ScrollView {
                            LazyVStack(spacing: DS.Spacing.md) {
                                ForEach(hospitalData.plantsInTreatment) { plant in
                                    NavigationLink(destination: PlantDetailView(plant: plant)) {
                                        PlantCard(plant: plant)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, DS.Spacing.md)
                            .padding(.vertical, DS.Spacing.sm)
                        }
                    }
                }
            }
            .navigationTitle("Hospital")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingAddPlant = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(DS.ColorSet.brand)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, DS.Spacing.lg)
                        .padding(.bottom, DS.Spacing.lg)
                    }
                }
            )
        }
        .sheet(isPresented: $showingAddPlant) {
            AddPlantManuallyView()
        }
    }
}

struct PlantCard: View {
    let plant: PlantInTreatment
    
    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            // Plant Photo
            Group {
                if let photo = plant.latestPhoto {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "photo")
                        .font(.system(size: 24))
                        .foregroundColor(DS.ColorSet.textSecondary)
                }
            }
            .frame(width: 60, height: 60)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .clipped()
            
            // Plant Info
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                HStack {
                    Text(plant.name)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(DS.ColorSet.textPrimary)
                    
                    Spacer()
                    
                    // Status Badge
                    HStack(spacing: 4) {
                        Image(systemName: plant.status.iconName)
                            .font(.system(size: 12, weight: .medium))
                        
                        Text(plant.status.rawValue)
                            .font(.caption.weight(.medium))
                    }
                    .foregroundColor(Color(plant.status.color))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(plant.status.color).opacity(0.1))
                    .cornerRadius(12)
                }
                
                Text(plant.disease)
                    .font(.subheadline)
                    .foregroundColor(DS.ColorSet.textSecondary)
                
                Text("Última atualização: \(plant.lastUpdate.formatted(.dateTime.day().month(.abbreviated)))")
                    .font(.caption)
                    .foregroundColor(DS.ColorSet.textSecondary)
            }
            
            Spacer()
        }
        .padding(DS.Spacing.md)
        .background(Color.white)
        .cornerRadius(DS.Radius.lg)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Add Plant Manually View
struct AddPlantManuallyView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var hospitalData = HospitalDataManager.shared
    
    @State private var plantName = ""
    @State private var selectedDisease: CommonDisease?
    @State private var customDisease = ""
    @State private var customTreatment = ""
    @State private var notes = ""
    @State private var selectedPhoto: UIImage?
    @State private var showingImagePicker = false
    @State private var showingDiseasePicker = false
    @State private var showingCustomDisease = false
    
    private var isFormValid: Bool {
        !plantName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (selectedDisease != nil || (!customDisease.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !customTreatment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)) &&
        selectedPhoto != nil
    }
    
    var body: some View {
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
                        // Photo Section
                        PhotoSection(
                            selectedPhoto: $selectedPhoto,
                            showingImagePicker: $showingImagePicker
                        )
                        
                        // Plant Name Section
                        PlantNameSection(plantName: $plantName)
                        
                        // Disease Selection Section
                        DiseaseSelectionSection(
                            selectedDisease: $selectedDisease,
                            customDisease: $customDisease,
                            customTreatment: $customTreatment,
                            showingDiseasePicker: $showingDiseasePicker,
                            showingCustomDisease: $showingCustomDisease
                        )
                        
                        // Notes Section
                        NotesSection(notes: $notes)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, DS.Spacing.md)
                    .padding(.top, DS.Spacing.md)
                }
            }
            .navigationTitle("Nova Análise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(DS.ColorSet.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        savePlant()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid)
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedPhoto)
        }
        .sheet(isPresented: $showingDiseasePicker) {
            DiseasePickerView(selectedDisease: $selectedDisease)
        }
        .sheet(isPresented: $showingCustomDisease) {
            CustomDiseaseView(
                customDisease: $customDisease,
                customTreatment: $customTreatment
            )
        }
    }
    
    private func savePlant() {
        guard let photo = selectedPhoto else { return }
        
        let diseaseName: String
        let treatment: String
        
        if let selectedDisease = selectedDisease {
            diseaseName = selectedDisease.name
            treatment = selectedDisease.treatment
        } else {
            diseaseName = customDisease.trimmingCharacters(in: .whitespacesAndNewlines)
            treatment = customTreatment.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        let plant = PlantInTreatment(
            name: plantName.trimmingCharacters(in: .whitespacesAndNewlines),
            disease: diseaseName,
            photo: photo,
            treatment: treatment
        )
        
        // Add notes if provided
        if !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            var plantWithNotes = plant
            let analysis = PlantAnalysis(
                photo: photo,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            plantWithNotes.addAnalysis(analysis)
            hospitalData.addPlant(plantWithNotes)
        } else {
            hospitalData.addPlant(plant)
        }
        
        dismiss()
    }
}

// MARK: - Photo Section
struct PhotoSection: View {
    @Binding var selectedPhoto: UIImage?
    @Binding var showingImagePicker: Bool
    
    var body: some View {
        VStack(spacing: DS.Spacing.md) {
            Text("Foto da Planta")
                .font(.headline.weight(.semibold))
                .foregroundColor(DS.ColorSet.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ImagePickerActionSheet(
                selectedImage: $selectedPhoto,
                showingImagePicker: $showingImagePicker
            )
        }
        .padding(DS.Spacing.md)
        .background(Color.white)
        .cornerRadius(DS.Radius.lg)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Plant Name Section
struct PlantNameSection: View {
    @Binding var plantName: String
    
    var body: some View {
        VStack(spacing: DS.Spacing.md) {
            Text("Nome da Planta")
                .font(.headline.weight(.semibold))
                .foregroundColor(DS.ColorSet.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Ex: Tomate, Rosa, Orquídea...", text: $plantName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.body)
        }
        .padding(DS.Spacing.md)
        .background(Color.white)
        .cornerRadius(DS.Radius.lg)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Disease Selection Section
struct DiseaseSelectionSection: View {
    @Binding var selectedDisease: CommonDisease?
    @Binding var customDisease: String
    @Binding var customTreatment: String
    @Binding var showingDiseasePicker: Bool
    @Binding var showingCustomDisease: Bool
    
    var body: some View {
        VStack(spacing: DS.Spacing.md) {
            Text("Doença ou Condição")
                .font(.headline.weight(.semibold))
                .foregroundColor(DS.ColorSet.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: DS.Spacing.sm) {
                // Selected Disease Display
                if let disease = selectedDisease {
                    VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                        HStack {
                            Image(systemName: disease.iconName)
                                .foregroundColor(DS.ColorSet.brand)
                            
                            Text(disease.name)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(DS.ColorSet.textPrimary)
                            
                            Spacer()
                            
                            Button("Alterar") {
                                selectedDisease = nil
                            }
                            .font(.caption)
                            .foregroundColor(DS.ColorSet.brand)
                        }
                        
                        Text(disease.description)
                            .font(.caption)
                            .foregroundColor(DS.ColorSet.textSecondary)
                            .lineLimit(2)
                    }
                    .padding(DS.Spacing.sm)
                    .background(DS.ColorSet.brandMuted.opacity(0.3))
                    .cornerRadius(DS.Radius.sm)
                } else if !customDisease.isEmpty {
                    VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                        HStack {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(DS.ColorSet.brand)
                            
                            Text(customDisease)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(DS.ColorSet.textPrimary)
                            
                            Spacer()
                            
                            Button("Alterar") {
                                customDisease = ""
                                customTreatment = ""
                            }
                            .font(.caption)
                            .foregroundColor(DS.ColorSet.brand)
                        }
                        
                        Text("Tratamento personalizado")
                            .font(.caption)
                            .foregroundColor(DS.ColorSet.textSecondary)
                    }
                    .padding(DS.Spacing.sm)
                    .background(DS.ColorSet.brandMuted.opacity(0.3))
                    .cornerRadius(DS.Radius.sm)
                } else {
                    // Selection Buttons
                    HStack(spacing: DS.Spacing.sm) {
                        Button(action: {
                            showingDiseasePicker = true
                        }) {
                            HStack {
                                Image(systemName: "list.bullet")
                                    .font(.system(size: 14, weight: .medium))
                                
                                Text("Doenças Comuns")
                                    .font(.subheadline.weight(.medium))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DS.Spacing.sm)
                            .background(DS.ColorSet.brand)
                            .cornerRadius(DS.Radius.sm)
                        }
                        
                        Button(action: {
                            showingCustomDisease = true
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                    .font(.system(size: 14, weight: .medium))
                                
                                Text("Personalizado")
                                    .font(.subheadline.weight(.medium))
                            }
                            .foregroundColor(DS.ColorSet.brand)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DS.Spacing.sm)
                            .background(DS.ColorSet.brand.opacity(0.1))
                            .cornerRadius(DS.Radius.sm)
                        }
                    }
                }
            }
        }
        .padding(DS.Spacing.md)
        .background(Color.white)
        .cornerRadius(DS.Radius.lg)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Notes Section
struct NotesSection: View {
    @Binding var notes: String
    
    var body: some View {
        VStack(spacing: DS.Spacing.md) {
            Text("Observações (Opcional)")
                .font(.headline.weight(.semibold))
                .foregroundColor(DS.ColorSet.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Adicione observações sobre a planta...", text: $notes)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.body)
                .lineLimit(3...6)
        }
        .padding(DS.Spacing.md)
        .background(Color.white)
        .cornerRadius(DS.Radius.lg)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    HospitalView()
}
