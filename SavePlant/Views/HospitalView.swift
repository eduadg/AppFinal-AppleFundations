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
                        // Plants List com swipe-to-delete
                        List {
                            ForEach(hospitalData.plantsInTreatment) { plant in
                                NavigationLink(destination: PlantDetailView(plant: plant)) {
                                    PlantCardRow(plantId: plant.id)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        hospitalData.removePlant(withId: plant.id)
                                    } label: {
                                        Label("Excluir", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
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

struct PlantCardRow: View {
    let plantId: UUID
    @StateObject private var hospitalData = HospitalDataManager.shared
    
    private var plant: PlantInTreatment? {
        hospitalData.plantsInTreatment.first(where: { $0.id == plantId })
    }
    
    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            // Plant Photo
            Group {
                if let photo = plant?.latestPhoto {
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
                                    let plantName = plant?.name ?? ""
                Text(plantName)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(DS.ColorSet.textPrimary)
                
                Spacer()
                
                // Status Badge
                let currentStatus = plant?.status ?? .inTreatment
                    HStack(spacing: 4) {
                        Image(systemName: currentStatus.iconName)
                            .font(.system(size: 12, weight: .medium))
                        
                        Text(currentStatus.rawValue)
                            .font(.caption.weight(.medium))
                    }
                    .foregroundColor(Color(currentStatus.color))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(currentStatus.color).opacity(0.1))
                    .cornerRadius(12)
                }
                
                let diseaseName = plant?.disease ?? ""
                Text(diseaseName)
                    .font(.subheadline)
                    .foregroundColor(DS.ColorSet.textSecondary)
                
                let lastUpdate = plant?.lastUpdate ?? Date()
                Text("Última atualização: \(lastUpdate.formatted(.dateTime.day().month(.abbreviated)))")
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
    
    // Estados para classificação automática
    @State private var isPredicting = false
    @State private var lastConfidence: Double = 0
    
    // Estados para identificação de planta
    @State private var isIdentifyingPlant = false
    @State private var plantIdentificationResult: PlantInfo?
    @State private var showingPlantIdentificationAlert = false
    @State private var plantIdentificationError: String?
    @State private var pickedFilename: String = ""
    
    private var isFormValid: Bool {
        let trimmedPlantName = plantName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCustomDisease = customDisease.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCustomTreatment = customTreatment.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let hasPlantName = !trimmedPlantName.isEmpty
        let hasDiseaseOrCustom = selectedDisease != nil || (!trimmedCustomDisease.isEmpty && !trimmedCustomTreatment.isEmpty)
        let hasPhoto = selectedPhoto != nil
        
        return hasPlantName && hasDiseaseOrCustom && hasPhoto
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
                            showingImagePicker: $showingImagePicker,
                            isPredicting: isPredicting,
                            lastConfidence: lastConfidence,
                            isIdentifyingPlant: isIdentifyingPlant,
                            plantIdentificationResult: plantIdentificationResult
                        )
                        
                        // Plant Name Section + sugestões
                        PlantNameSection(plantName: $plantName)
                        SuggestedDiseasesSection(plantName: $plantName, onSelectDisease: { disease in
                            print("🔄 Doença selecionada: \(disease.name)")
                            print("🔄 Estado antes - selectedDisease: \(self.selectedDisease?.name ?? "nil"), customDisease: \(self.customDisease), customTreatment: \(self.customTreatment)")
                            
                            self.selectedDisease = disease
                            self.customDisease = disease.name
                            self.customTreatment = disease.treatment
                            
                            print("✅ Estado após - selectedDisease: \(self.selectedDisease?.name ?? "nil"), customDisease: \(self.customDisease), customTreatment: \(self.customTreatment)")
                        })
                        
                        // Disease Selection Section
                        DiseaseSelectionSection(
                            selectedDisease: $selectedDisease,
                            customDisease: $customDisease,
                            customTreatment: $customTreatment,
                            showingDiseasePicker: $showingDiseasePicker,
                            showingCustomDisease: $showingCustomDisease
                        )
                        .onChange(of: selectedDisease) { _, newValue in
                            if let disease = newValue {
                                self.customTreatment = disease.treatment
                                self.customDisease = disease.name
                            }
                        }
                        
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
        .sheet(isPresented: $showingDiseasePicker) {
            DiseasePickerView(selectedDisease: $selectedDisease)
        }
        .sheet(isPresented: $showingCustomDisease) {
            CustomDiseaseView(
                customDisease: $customDisease,
                customTreatment: $customTreatment
            )
        }
        .alert("Erro na Identificação", isPresented: $showingPlantIdentificationAlert) {
            Button("OK") { }
        } message: {
            Text(plantIdentificationError ?? "Erro desconhecido na identificação da planta")
        }
        .onChange(of: selectedPhoto) { oldValue, newValue in
            guard let newImage = newValue else { return }
            
            // 1) Regras fake por nome de arquivo, se disponível
            if let rule = FakePlantRules.match(from: pickedFilename) {
                applyFakeRule(rule)
            } else {
                // 2) Tenta API PlantNet
                identifyPlant(newImage)
            }
            
            // Identificar a planta primeiro
            // (feito acima)
            
            // Depois classificar a doença (se o classificador estiver disponível)
            if let classifier = PlantDiseaseClassifier.shared {
                classifyDisease(newImage, using: classifier)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .imagePickerSelectedFileName)) { notification in
            if let filename = notification.userInfo?["filename"] as? String {
                self.pickedFilename = filename
            }
        }
    }
    
    // MARK: - Plant Identification (PlantNet)
    private func identifyPlant(_ image: UIImage) {
        isIdentifyingPlant = true
        
        PlantNetService.shared.identifyPlant(image: image) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let plantInfo):
                    self.isIdentifyingPlant = false
                    self.plantIdentificationResult = plantInfo
                    
                    if self.plantName.isEmpty {
                        self.plantName = plantInfo.name
                    }
                    
                    var scientificInfo = "Planta identificada: \(plantInfo.name)"
                    if let scientificName = plantInfo.scientificName { scientificInfo += "\nNome científico: \(scientificName)" }
                    if let family = plantInfo.family { scientificInfo += "\nFamília: \(family)" }
                    if !plantInfo.commonNames.isEmpty { scientificInfo += "\nNomes comuns: \(plantInfo.commonNames.joined(separator: ", "))" }
                    scientificInfo += "\nConfiança: \(Int(plantInfo.confidence * 100))%"
                    self.notes = scientificInfo
                case .failure:
                    // Fallback offline com modelo local
                    self.fallbackIdentifyWithLocalModel(image)
                }
            }
        }
    }

    // MARK: - Fallback local (Core ML)
    private func fallbackIdentifyWithLocalModel(_ image: UIImage) {
        guard let classifier = PlantDiseaseClassifier.shared else {
            self.isIdentifyingPlant = false
            self.plantIdentificationError = "Não foi possível inicializar o classificador local."
            self.showingPlantIdentificationAlert = true
            return
        }
        classifier.classify(image) { pred in
            DispatchQueue.main.async {
                self.isIdentifyingPlant = false
                guard let pred = pred else {
                    self.plantIdentificationError = "Falha na identificação offline."
                    self.showingPlantIdentificationAlert = true
                    return
                }

                // Preenche planta
                if self.plantName.isEmpty, !pred.plant.isEmpty {
                    self.plantName = pred.plant
                }

                // Preenche doença/treatment conforme lógica existente
                if let match = self.tryMatchCommonDisease(named: pred.disease) {
                    self.selectedDisease = match
                    self.customDisease = ""
                    self.customTreatment = ""
                } else {
                    self.selectedDisease = nil
                    self.customDisease = pred.disease
                }

                self.lastConfidence = pred.confidence

                // Observações informando fallback offline
                let fallbackInfo = "Identificação offline (modelo local) com \(Int(pred.confidence * 100))% de confiança."
                if self.notes.isEmpty {
                    self.notes = fallbackInfo
                } else {
                    self.notes += "\n\n" + fallbackInfo
                }
            }
        }
    }

    // MARK: - Aplicar regra fake (por nome de arquivo)
    private func applyFakeRule(_ rule: FakePlantRule) {
        // Preenche nome da planta se estiver vazio
        if self.plantName.isEmpty {
            self.plantName = rule.plantName
        }

        // Casa doença com lista comum, senão usa personalizada
        if let match = self.tryMatchCommonDisease(named: rule.diseaseName) {
            self.selectedDisease = match
            self.customDisease = ""
            self.customTreatment = ""
        } else {
            self.selectedDisease = nil
            self.customDisease = rule.diseaseName
        }

        // Observações
        if self.notes.isEmpty {
            self.notes = rule.note
        } else {
            self.notes += "\n\n" + rule.note
        }
    }
    
    // MARK: - Disease Classification
    private func classifyDisease(_ image: UIImage, using classifier: PlantDiseaseClassifier) {
        guard !isPredicting else { return }
        
        isPredicting = true
        classifier.classify(image) { pred in
            DispatchQueue.main.async {
                self.isPredicting = false
                guard let pred = pred else { return }

                // Tenta casar com suas doenças comuns; se não houver, usa personalizado
                if let match = self.tryMatchCommonDisease(named: pred.disease) {
                    self.selectedDisease = match
                    self.customDisease = ""
                    self.customTreatment = ""
                } else {
                    self.selectedDisease = nil
                    self.customDisease = pred.disease
                    // TODO: se quiser, preencha tratamento padrão aqui
                }

                // Atualiza a confiança para mostrar na UI
                self.lastConfidence = pred.confidence
            }
        }
    }
    
    private func savePlant() {
        guard let photo = selectedPhoto else { return }
        
        print("💾 Salvando planta...")
        print("📝 Nome: \(plantName)")
        print("🦠 Doença selecionada: \(selectedDisease?.name ?? "Nenhuma")")
        print("🦠 Doença customizada: \(customDisease)")
        print("💊 Tratamento customizado: \(customTreatment)")
        
        let diseaseName: String
        let treatment: String
        
        if let selectedDisease = selectedDisease {
            diseaseName = selectedDisease.name
            treatment = selectedDisease.treatment
            print("✅ Usando doença selecionada: \(diseaseName)")
        } else {
            diseaseName = customDisease.trimmingCharacters(in: .whitespacesAndNewlines)
            treatment = customTreatment.trimmingCharacters(in: .whitespacesAndNewlines)
            print("✅ Usando doença customizada: \(diseaseName)")
        }
        
        let trimmedPlantName = plantName.trimmingCharacters(in: .whitespacesAndNewlines)
        let plant = PlantInTreatment(
            name: trimmedPlantName,
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
    
    // Helper para tentar casar a doença reconhecida com a lista de doenças comuns
    private func tryMatchCommonDisease(named name: String) -> CommonDisease? {
        let key = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Busca por correspondência exata ou parcial nas doenças comuns
        return CommonDisease.commonDiseases.first { disease in
            let diseaseName = disease.name.lowercased()
            return diseaseName.contains(key) || key.contains(diseaseName)
        }
    }
}

// MARK: - Photo Section
struct PhotoSection: View {
    @Binding var selectedPhoto: UIImage?
    @Binding var showingImagePicker: Bool
    let isPredicting: Bool
    let lastConfidence: Double
    let isIdentifyingPlant: Bool
    let plantIdentificationResult: PlantInfo?
    
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
            
            // Indicador de identificação da planta em andamento
            if isIdentifyingPlant {
                HStack(spacing: DS.Spacing.sm) {
                    ProgressView()
                        .scaleEffect(0.8)
                    
                    Text("Identificando planta...")
                        .font(.caption)
                        .foregroundColor(DS.ColorSet.textSecondary)
                }
                .padding(.top, DS.Spacing.sm)
            }
            
            // Indicador de classificação em andamento
            if isPredicting {
                HStack(spacing: DS.Spacing.sm) {
                    ProgressView()
                        .scaleEffect(0.8)
                    
                    Text("Analisando doença...")
                        .font(.caption)
                        .foregroundColor(DS.ColorSet.textSecondary)
                }
                .padding(.top, DS.Spacing.sm)
            }
            
            // Mensagem de sucesso da identificação da planta
            if !isIdentifyingPlant && plantIdentificationResult != nil {
                HStack(spacing: DS.Spacing.sm) {
                    Image(systemName: "leaf.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    
                    Text("Planta identificada: \(plantIdentificationResult?.name ?? "")")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                .padding(.top, DS.Spacing.sm)
            }
            
            // Mensagem de sucesso quando a classificação for concluída
            if !isPredicting && selectedPhoto != nil && lastConfidence > 0 {
                HStack(spacing: DS.Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    
                    Text("Doença analisada com \(Int(lastConfidence * 100))% de confiança")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.top, DS.Spacing.sm)
            }
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

// MARK: - Suggested Diseases Section (by Plant Name)
struct SuggestedDiseasesSection: View {
    @Binding var plantName: String
    var onSelectDisease: (CommonDisease) -> Void
    @State private var selected: CommonDisease?
    
    private var suggestions: [CommonDisease] {
        let diseases = PlantDiseaseKnowledgeBase.suggestDiseases(for: plantName)
        print("🔍 Sugestões para '\(plantName)': \(diseases.count) doenças encontradas")
        diseases.forEach { disease in
            print("  - \(disease.name): \(disease.treatment.prefix(50))...")
        }
        return diseases
    }
    
    var body: some View {
        let trimmedPlantName = plantName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedPlantName.isEmpty {
            return EmptyView()
        }
        
        return VStack(spacing: DS.Spacing.md) {
            // Header
            Text("Sugestões de Doenças para \(trimmedPlantName)")
                .font(.headline.weight(.semibold))
                .foregroundColor(DS.ColorSet.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Content based on state
            if suggestions.isEmpty {
                EmptySuggestionsView()
            } else if let selected = selected {
                SelectedDiseaseView(selected: selected) {
                    self.selected = nil
                }
            } else {
                DiseaseSuggestionsList(suggestions: suggestions) { disease in
                    self.selected = disease
                    onSelectDisease(disease)
                }
            }
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

// MARK: - Auxiliary Views for SuggestedDiseasesSection

struct EmptySuggestionsView: View {
    var body: some View {
        Text("Nenhuma sugestão encontrada para este nome.")
            .font(.caption)
            .foregroundColor(DS.ColorSet.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SelectedDiseaseView: View {
    let selected: CommonDisease
    let onAlterar: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack {
                Image(systemName: selected.iconName)
                    .font(.title2)
                    .foregroundColor(DS.ColorSet.brand)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Doença Selecionada")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(DS.ColorSet.brand)
                        .textCase(.uppercase)
                    Text(selected.name)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(DS.ColorSet.textPrimary)
                }
                Spacer()
                Button("Alterar", action: onAlterar)
                    .font(.caption)
                    .foregroundColor(DS.ColorSet.brand)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(selected.description)
                    .font(.subheadline)
                    .foregroundColor(DS.ColorSet.textSecondary)
                    .lineLimit(nil)
                
                HStack {
                    Image(systemName: "cross.case.fill")
                        .font(.caption)
                        .foregroundColor(DS.ColorSet.brand)
                    Text("Tratamento Recomendado:")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(DS.ColorSet.textPrimary)
                }
                
                Text(selected.treatment)
                    .font(.subheadline)
                    .foregroundColor(DS.ColorSet.textSecondary)
                    .padding(.leading, 20)
            }
        }
        .padding(DS.Spacing.md)
        .background(DS.ColorSet.brand.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.md)
                .stroke(DS.ColorSet.brand.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(DS.Radius.md)
    }
}

struct DiseaseSuggestionsList: View {
    let suggestions: [CommonDisease]
    let onSelectDisease: (CommonDisease) -> Void
    
    var body: some View {
        VStack(spacing: DS.Spacing.sm) {
            ForEach(suggestions, id: \.id) { disease in
                DiseaseSuggestionRow(disease: disease, onSelect: onSelectDisease)
            }
        }
    }
}

struct DiseaseSuggestionRow: View {
    let disease: CommonDisease
    let onSelect: (CommonDisease) -> Void
    
    var body: some View {
        Button(action: { onSelect(disease) }) {
            HStack(spacing: DS.Spacing.sm) {
                Image(systemName: disease.iconName)
                    .font(.title3)
                    .foregroundColor(DS.ColorSet.brand)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(disease.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(DS.ColorSet.textPrimary)
                    Text(disease.description)
                        .font(.caption)
                        .foregroundColor(DS.ColorSet.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Selecionar")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(DS.ColorSet.brand)
                        .cornerRadius(8)
                    
                    Text("Tratamento disponível")
                        .font(.caption2)
                        .foregroundColor(DS.ColorSet.textSecondary)
                }
            }
            .padding(DS.Spacing.md)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.sm)
                    .stroke(DS.ColorSet.brand.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(DS.Radius.sm)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Preview comentado para evitar problemas de compilação
// #Preview {
//     HospitalView()
// }
