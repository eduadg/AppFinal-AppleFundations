import SwiftUI

public struct PlantDetailView: View {
    @State private var showingAddPhoto = false
    @State private var newPhoto: UIImage?
    @State private var showingGallery = false
    @State private var galleryIndex: Int = 0
    @StateObject private var hospitalData = HospitalDataManager.shared
    @Environment(\.dismiss) private var dismiss
    
    private let plantId: UUID
    
    public init(plant: PlantInTreatment) {
        self.plantId = plant.id
    }
    
    // Computed property para sempre pegar a planta mais atualizada
    private var plant: PlantInTreatment? {
        hospitalData.plantsInTreatment.first(where: { $0.id == plantId })
    }
    
    public var body: some View {
        Group {
            if let currentPlant = plant {
                ScrollView {
                    VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                        // Main Photo Section
                        if let latestPhoto = currentPlant.latestPhoto {
                    Image(uiImage: latestPhoto)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 260)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                        .contentShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                } else {
                    RoundedRectangle(cornerRadius: DS.Radius.lg)
                        .fill(Color(.systemGray6))
                        .frame(height: 300)
                        .overlay(
                            VStack {
                                Image(systemName: "photo")
                                    .font(.system(size: 48))
                                    .foregroundColor(.secondary)
                                Text("Nenhuma foto disponível")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        )
                }
                
                // Plant Info Header
                VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                    HStack {
                        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                            Text(plant.name)
                                .font(.title.weight(.bold))
                                .foregroundColor(DS.ColorSet.textPrimary)
                            
                            Text(plant.disease)
                                .font(.headline)
                                .foregroundColor(DS.ColorSet.textSecondary)
                        }
                        
                        Spacer()
                        
                        // Status Indicator
                        VStack(spacing: DS.Spacing.xs) {
                            Image(systemName: currentHeaderStatus.iconName)
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(Color(currentHeaderStatus.color))
                            
                            Text(currentHeaderStatus.rawValue)
                                .font(.caption.weight(.medium))
                                .foregroundColor(Color(currentHeaderStatus.color))
                        }
                        .padding(DS.Spacing.md)
                        .background(Color(currentHeaderStatus.color).opacity(0.1))
                        .cornerRadius(DS.Radius.md)
                    }
                    
                                    let diagnosisDate = currentPlant.diagnosisDate
                let formattedDate = diagnosisDate.formatted(.dateTime.day().month(.abbreviated).year())
                Text("Diagnóstico em \(formattedDate)")
                    .font(.caption)
                    .foregroundColor(DS.ColorSet.textSecondary)
                }
                
                // Status Update Section (lê e atualiza direto da store pelo ID)
                StatusUpdateSection(plantId: currentPlant.id)
                
                // Treatment Section
                TreatmentSection(treatment: currentPlant.treatment)
                
                // Timeline Section (tap para abrir galeria)
                TimelineSection(analyses: currentPlant.timeline, onSelectIndex: { idx in
                    self.galleryIndex = idx
                    self.showingGallery = true
                })
                
                // Add Photo Button
                Button(action: {
                    showingAddPhoto = true
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Adicionar nova foto")
                            .font(.headline.weight(.semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(DS.Spacing.md)
                    .background(DS.ColorSet.brand)
                    .cornerRadius(DS.Radius.md)
                }
                .padding(.top, DS.Spacing.md)
            }
            .padding(DS.Spacing.md)
        }
        .navigationTitle("Detalhes da Planta")
    } else {
        // Planta não encontrada
        VStack(spacing: DS.Spacing.lg) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 64))
                .foregroundColor(.orange)
            
            Text("Planta não encontrada")
                .font(.title2.weight(.semibold))
                .foregroundColor(DS.ColorSet.textPrimary)
            
            Text("A planta pode ter sido removida ou não está mais disponível")
                .font(.body)
                .foregroundColor(DS.ColorSet.textSecondary)
                .multilineTextAlignment(.center)
            
            Button("Voltar") {
                dismiss()
            }
            .foregroundColor(.white)
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.vertical, DS.Spacing.md)
            .background(DS.ColorSet.brand)
            .cornerRadius(DS.Radius.md)
            
            Spacer()
        }
        .padding(DS.Spacing.lg)
    }
}
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddPhoto) {
            ImagePicker(selectedImage: $newPhoto, sourceType: .photoLibrary)
        }
        .onChange(of: newPhoto) { _, img in
            guard let img = img,
                  let currentPlant = plant else { return }
            
            print("🔄 Adicionando nova foto à planta: \(currentPlant.name)")
            
            // Cria nova análise com a foto
            let newAnalysis = PlantAnalysis(photo: img, date: Date())
            
            // Atualiza a planta
            var updated = currentPlant
            updated.addAnalysis(newAnalysis)
            
            print("📸 Total de análises após adicionar: \(updated.analyses.count)")
            print("🎯 Foto mais recente mudou: \(updated.latestPhoto != nil)")
            
            // Atualiza no store - isso vai automaticamente atualizar a UI
            hospitalData.updatePlant(updated)
            
            // Reset do estado da foto para permitir nova seleção
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.newPhoto = nil
            }
            
            print("✅ Nova foto adicionada com sucesso")
        }
        .fullScreenCover(isPresented: $showingGallery) {
            if let currentPlant = plant {
                PhotoPagerView(analyses: currentPlant.timeline, currentIndex: $galleryIndex)
            }
        }
        // Removido onReceive - não é mais necessário com @StateObject
    }
}

private extension PlantDetailView {
    var currentHeaderStatus: PlantStatus {
        guard let currentPlant = plant else { return .inTreatment }
        return currentPlant.status
    }
}

struct StatusUpdateSection: View {
    let plantId: UUID
    @StateObject private var hospitalData = HospitalDataManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Atualizar Status")
                .font(.headline.weight(.semibold))
                .foregroundColor(DS.ColorSet.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: DS.Spacing.sm), count: 2), spacing: DS.Spacing.sm) {
                ForEach(PlantStatus.allCases, id: \.self) { status in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            hospitalData.updateStatus(for: plantId, to: status)
                        }
                    }) {
                        HStack(spacing: DS.Spacing.xs) {
                            Image(systemName: status.iconName)
                                .font(.system(size: 14, weight: .medium))
                            
                            Text(status.rawValue)
                                .font(.caption.weight(.medium))
                        }
                        .foregroundColor(currentStatus == status ? .white : Color(status.color))
                        .padding(.horizontal, DS.Spacing.sm)
                        .padding(.vertical, DS.Spacing.xs)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(currentStatus == status ? Color(status.color) : Color(status.color).opacity(0.1))
                        .cornerRadius(DS.Radius.sm)
                    }
                }
            }
        }
        .padding(DS.Spacing.md)
        .background(Color.white)
        .cornerRadius(DS.Radius.lg)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    private var currentStatus: PlantStatus {
        let status = hospitalData.plantsInTreatment.first(where: { $0.id == plantId })?.status
        return status ?? .inTreatment
    }
}

struct TreatmentSection: View {
    let treatment: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(DS.ColorSet.brand)
                
                Text("Tratamento Recomendado")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(DS.ColorSet.textPrimary)
            }
            
            Text(treatment)
                .font(.body)
                .foregroundColor(DS.ColorSet.textSecondary)
                .lineSpacing(4)
        }
        .padding(DS.Spacing.md)
        .background(Color.white)
        .cornerRadius(DS.Radius.lg)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

struct TimelineSection: View {
    let analyses: [PlantAnalysis]
    var onSelectIndex: (Int) -> Void = { _ in }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(DS.ColorSet.brand)
                
                Text("Linha do Tempo")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(DS.ColorSet.textPrimary)
            }
            
            if analyses.isEmpty {
                Text("Nenhuma análise registrada")
                    .font(.body)
                    .foregroundColor(DS.ColorSet.textSecondary)
                    .padding(.vertical, DS.Spacing.lg)
            } else {
                LazyVStack(spacing: DS.Spacing.md) {
                    ForEach(Array(analyses.enumerated()), id: \.offset) { index, analysis in
                        Button(action: { onSelectIndex(index) }) {
                            TimelineItem(
                                analysis: analysis,
                                isLatest: index == 0  // Primeira da lista ordenada por data decrescente
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
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

struct TimelineItem: View {
    let analysis: PlantAnalysis
    let isLatest: Bool
    
    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            // Timeline indicator
            VStack {
                Circle()
                    .fill(isLatest ? DS.ColorSet.brand : DS.ColorSet.textSecondary)
                    .frame(width: 12, height: 12)
                
                if !isLatest {
                    Rectangle()
                        .fill(DS.ColorSet.textSecondary.opacity(0.3))
                        .frame(width: 2, height: 30)
                }
            }
            
            // Photo thumbnail
            Image(uiImage: analysis.photo)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .cornerRadius(8)
                .clipped()
            
            // Date and notes
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                HStack {
                    let formattedTime = analysis.date.formatted(.dateTime.day().month(.abbreviated).hour().minute())
                    Text(formattedTime)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(DS.ColorSet.textPrimary)
                    
                    if isLatest {
                        Text("ATUAL")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(DS.ColorSet.brand)
                            .cornerRadius(4)
                    }
                }
                
                if let notes = analysis.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(DS.ColorSet.textSecondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
        }
    }
}

// Visualizador de fotos com navegação por versões (somente leitura)
struct PhotoPagerView: View {
    let analyses: [PlantAnalysis]
    @Binding var currentIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            TabView(selection: $currentIndex) {
                ForEach(Array(analyses.enumerated()), id: \.offset) { idx, analysis in
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        Image(uiImage: analysis.photo)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .tag(idx)
                        VStack(spacing: 6) {
                            let formattedDateTime = analysis.date.formatted(.dateTime.day().month(.abbreviated).year().hour().minute())
                            Text(formattedDateTime)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            if let notes = analysis.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 12)
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                    }
                    .padding()
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

// Preview comentado para evitar problemas de compilação
// #Preview {
//     NavigationView {
//         if let mockImage = UIImage(systemName: "leaf.fill") {
//             let mockImage = UIImage(systemName: "leaf.fill") {
//                 let mockPlant = PlantInTreatment(
//                     name: "Tomate",
//                     disease: "Mancha bacteriana",
//                     photo: mockImage,
//                     treatment: "Aplicar fungicida à base de cobre. Evitar molhar as folhas durante a rega."
//             )
//             PlantDetailView(plant: mockPlant)
//         }
//     }
// }
