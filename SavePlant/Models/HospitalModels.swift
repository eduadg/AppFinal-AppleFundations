import Foundation
import UIKit
import SwiftData

// MARK: - Common Diseases
public struct CommonDisease: Identifiable, Hashable {
    public let id = UUID()
    public let name: String
    public let description: String
    public let treatment: String
    public let iconName: String
    
    public init(name: String, description: String, treatment: String, iconName: String) {
        self.name = name
        self.description = description
        self.treatment = treatment
        self.iconName = iconName
    }
    
    public static let commonDiseases: [CommonDisease] = [
        CommonDisease(
            name: "Mancha Bacteriana",
            description: "Manchas marrons ou pretas nas folhas, causadas por bactérias",
            treatment: "Aplicar fungicida à base de cobre. Evitar molhar as folhas durante a rega. Melhorar ventilação entre as plantas.",
            iconName: "circle.fill"
        ),
        CommonDisease(
            name: "Míldio",
            description: "Manchas amarelas nas folhas com crescimento branco na parte inferior",
            treatment: "Aplicar fungicida sistêmico. Reduzir umidade. Melhorar circulação de ar.",
            iconName: "cloud.rain.fill"
        ),
        CommonDisease(
            name: "Oídio",
            description: "Pó branco ou cinza nas folhas e caules",
            treatment: "Aplicar fungicida específico para oídio. Reduzir umidade. Podar partes afetadas.",
            iconName: "snowflake"
        ),
        CommonDisease(
            name: "Ferrugem",
            description: "Manchas laranja ou marrom nas folhas",
            treatment: "Aplicar fungicida preventivo. Remover folhas infectadas. Melhorar ventilação.",
            iconName: "flame.fill"
        ),
        CommonDisease(
            name: "Podridão Radicular",
            description: "Raízes marrons e moles, planta murcha",
            treatment: "Reduzir rega. Melhorar drenagem do solo. Aplicar fungicida no solo.",
            iconName: "root"
        ),
        CommonDisease(
            name: "Vírus do Mosaico",
            description: "Padrão de mosaico nas folhas, crescimento atrofiado",
            treatment: "Remover plantas infectadas. Controlar insetos vetores. Usar sementes certificadas.",
            iconName: "square.grid.3x3.fill"
        ),
        CommonDisease(
            name: "Deficiência Nutricional",
            description: "Folhas amarelas, crescimento lento",
            treatment: "Aplicar fertilizante balanceado. Verificar pH do solo. Fazer análise do solo.",
            iconName: "leaf.fill"
        ),
        CommonDisease(
            name: "Outro",
            description: "Outra condição ou doença não listada",
            treatment: "Consulte um especialista para diagnóstico preciso e tratamento adequado.",
            iconName: "questionmark.circle.fill"
        )
    ]
}

// MARK: - Plant Status
public enum PlantStatus: String, CaseIterable {
    case inTreatment = "Em tratamento"
    case cured = "Curada"
    case worsening = "Piorando"
    case stable = "Estável"
    case improving = "Melhorando"

    // Removemos "Estável" da listagem exibida ao usuário
    public static var allCases: [PlantStatus] { [.inTreatment, .cured, .worsening, .improving] }
    
    var color: UIColor {
        switch self {
        case .inTreatment:
            return UIColor.systemOrange
        case .cured:
            return UIColor.systemGreen
        case .worsening:
            return UIColor.systemRed
        case .stable:
            return UIColor.systemYellow
        case .improving:
            return UIColor.systemBlue
        }
    }
    
    var iconName: String {
        switch self {
        case .inTreatment:
            return "cross.case.fill"
        case .cured:
            return "checkmark.seal.fill"
        case .worsening:
            return "arrow.down.circle.fill"
        case .stable:
            return "minus.circle.fill"
        case .improving:
            return "arrow.up.circle.fill"
        }
    }
}

// MARK: - Plant Analysis Entry
public struct PlantAnalysis: Identifiable, Equatable {
    public let id = UUID()
    public let photo: UIImage
    public let date: Date
    public let notes: String?
    
    public init(photo: UIImage, date: Date = Date(), notes: String? = nil) {
        self.photo = photo
        self.date = date
        self.notes = notes
    }
    
    // MARK: - Equatable
    public static func == (lhs: PlantAnalysis, rhs: PlantAnalysis) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Plant in Treatment
public struct PlantInTreatment: Identifiable, Equatable {
    public var id = UUID()
    public let name: String
    public let disease: String
    public var status: PlantStatus
    public var diagnosisDate: Date
    public var lastUpdate: Date
    public var analyses: [PlantAnalysis]
    public let treatment: String
    
    // Computed properties
    public var latestPhoto: UIImage? {
        analyses.last?.photo
    }
    
    public var timeline: [PlantAnalysis] {
        analyses.sorted { $0.date > $1.date }
    }
    
    public init(name: String, disease: String, status: PlantStatus = .inTreatment, photo: UIImage, treatment: String) {
        self.name = name
        self.disease = disease
        self.status = status
        self.diagnosisDate = Date()
        self.lastUpdate = Date()
        self.treatment = treatment
        self.analyses = [PlantAnalysis(photo: photo)]
    }
    
    public mutating func addAnalysis(_ analysis: PlantAnalysis) {
        analyses.append(analysis)
        lastUpdate = Date()
    }
    
    public mutating func updateStatus(_ newStatus: PlantStatus) {
        status = newStatus
        lastUpdate = Date()
    }
    
    // MARK: - Equatable
    public static func == (lhs: PlantInTreatment, rhs: PlantInTreatment) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hospital Data Manager
public class HospitalDataManager: ObservableObject {
    @Published public var plantsInTreatment: [PlantInTreatment] = []
    
    public static let shared = HospitalDataManager()
    private var context: ModelContext?
    
    private init() {
        // aguardará contexto ser injetado pelo App
    }
    
    public func setContext(_ context: ModelContext) {
        self.context = context
        loadFromStorage()
    }
    
    public func addPlant(_ plant: PlantInTreatment) {
        plantsInTreatment.append(plant)
        saveToStorage()
    }
    
    public func updatePlant(_ plant: PlantInTreatment) {
        if let index = plantsInTreatment.firstIndex(where: { $0.id == plant.id }) {
            plantsInTreatment[index] = plant
            saveToStorage()
        }
    }

    public func updateStatus(for plantId: UUID, to status: PlantStatus) {
        if let idx = plantsInTreatment.firstIndex(where: { $0.id == plantId }) {
            var updated = plantsInTreatment[idx]
            updated.updateStatus(status)
            plantsInTreatment[idx] = updated   // reatribui para disparar @Published
            saveToStorage()
        }
    }
    
    public func removePlant(withId id: UUID) {
        plantsInTreatment.removeAll { $0.id == id }
        saveToStorage()
    }
    
    // MARK: - Mock Data
    // MARK: - SwiftData Persistence
    private func loadFromStorage() {
        guard let context = context else { 
            print("⚠️ Contexto SwiftData não inicializado")
            return 
        }
        do {
            let stored: [StoredPlant] = try context.fetch(FetchDescriptor<StoredPlant>())
            print("📱 Carregando \(stored.count) plantas do SwiftData")
            
            let mapped: [PlantInTreatment] = stored.compactMap { storedPlant in
                guard let plant = PlantInTreatment(stored: storedPlant) else {
                    print("⚠️ Falha ao converter StoredPlant para PlantInTreatment: \(storedPlant.name)")
                    return nil
                }
                return plant
            }
            
            print("✅ \(mapped.count) plantas convertidas com sucesso")
            self.plantsInTreatment = mapped
        } catch {
            print("❌ Erro ao carregar plantas do SwiftData: \(error)")
            self.plantsInTreatment = []
        }
    }
    
    private func saveToStorage() {
        guard let context = context else { return }
        do {
            // Limpa e regrava tudo (simples e seguro aqui)
            let existing: [StoredPlant] = try context.fetch(FetchDescriptor<StoredPlant>())
            for item in existing { context.delete(item) }
            for plant in plantsInTreatment {
                context.insert(StoredPlant.from(plant))
            }
            try context.save()
        } catch {
            // Em produção, tratar erro
        }
    }
}
