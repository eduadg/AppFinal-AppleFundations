import SwiftUI

public struct PlantDetailView: View {
    @State private var plant: PlantInTreatment
    @State private var showingAddPhoto = false
    @State private var newPhoto: UIImage?
    @StateObject private var hospitalData = HospitalDataManager.shared
    @Environment(\.dismiss) private var dismiss
    
    public init(plant: PlantInTreatment) {
        self._plant = State(initialValue: plant)
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                // Main Photo Section
                if let latestPhoto = plant.latestPhoto {
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
                    
                    Text("Diagnóstico em \(plant.diagnosisDate.formatted(.dateTime.day().month(.abbreviated).year()))")
                        .font(.caption)
                        .foregroundColor(DS.ColorSet.textSecondary)
                }
                
                // Status Update Section (lê e atualiza direto da store pelo ID)
                StatusUpdateSection(plantId: plant.id)
                
                // Treatment Section
                TreatmentSection(treatment: plant.treatment)
                
                // Timeline Section
                TimelineSection(analyses: plant.timeline)
                
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
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddPhoto) {
            ImagePicker(selectedImage: $newPhoto, sourceType: .photoLibrary)
        }
        .onChange(of: newPhoto) { _, img in
            guard let img = img else { return }
            // adiciona nova análise e atualiza no store
            var updated = plant
            updated.addAnalysis(PlantAnalysis(photo: img))
            hospitalData.updatePlant(updated)
            plant = updated
        }
        .onReceive(hospitalData.$plantsInTreatment) { list in
            if let updated = list.first(where: { $0.id == plant.id }) {
                plant = updated
            }
        }
    }
}

private extension PlantDetailView {
    var currentHeaderStatus: PlantStatus {
        hospitalData.plantsInTreatment.first(where: { $0.id == plant.id })?.status ?? plant.status
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
        hospitalData.plantsInTreatment.first(where: { $0.id == plantId })?.status ?? .inTreatment
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
                        TimelineItem(
                            analysis: analysis,
                            isLatest: index == analyses.count - 1
                        )
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
                Text(analysis.date.formatted(.dateTime.day().month(.abbreviated).hour().minute()))
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(DS.ColorSet.textPrimary)
                
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

// Placeholder for Add Photo View
struct AddPhotoView: View {
    @Binding var plant: PlantInTreatment
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Adicionar Nova Foto")
                    .font(.title2)
                    .padding()
                
                Text("Funcionalidade em desenvolvimento")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Nova Foto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        // TODO: Implement photo saving
                        dismiss()
                    }
                    .disabled(true)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        if let mockImage = UIImage(systemName: "leaf.fill") {
            let mockPlant = PlantInTreatment(
                name: "Tomate",
                disease: "Mancha bacteriana",
                photo: mockImage,
                treatment: "Aplicar fungicida à base de cobre. Evitar molhar as folhas durante a rega."
            )
            PlantDetailView(plant: mockPlant)
        }
    }
}
