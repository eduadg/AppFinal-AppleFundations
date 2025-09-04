import Foundation
import SwiftData
import UIKit

@Model
final class StoredAnalysis {
    @Attribute(.unique) var id: UUID
    var photoData: Data
    var date: Date
    var notes: String?
    
    init(id: UUID = UUID(), photoData: Data, date: Date = Date(), notes: String? = nil) {
        self.id = id
        self.photoData = photoData
        self.date = date
        self.notes = notes
    }
}

@Model
final class StoredPlant {
    @Attribute(.unique) var id: UUID
    var name: String
    var disease: String
    var statusRaw: String
    var diagnosisDate: Date
    var lastUpdate: Date
    var treatment: String
    var analyses: [StoredAnalysis]
    
    init(
        id: UUID = UUID(),
        name: String,
        disease: String,
        statusRaw: String,
        diagnosisDate: Date = Date(),
        lastUpdate: Date = Date(),
        treatment: String,
        analyses: [StoredAnalysis] = []
    ) {
        self.id = id
        self.name = name
        self.disease = disease
        self.statusRaw = statusRaw
        self.diagnosisDate = diagnosisDate
        self.lastUpdate = lastUpdate
        self.treatment = treatment
        self.analyses = analyses
    }
}

extension StoredAnalysis {
    var uiImage: UIImage? { UIImage(data: photoData) }
}

extension StoredPlant {
    var status: PlantStatus { PlantStatus(rawValue: statusRaw) ?? .inTreatment }
}

// MARK: - Mapping helpers
extension PlantInTreatment {
    init?(stored: StoredPlant) {
        // Verifica se os dados essenciais existem
        guard !stored.name.isEmpty,
              !stored.disease.isEmpty,
              !stored.treatment.isEmpty,
              !stored.analyses.isEmpty else {
            print("⚠️ StoredPlant com dados inválidos: name=\(stored.name), disease=\(stored.disease), treatment=\(stored.treatment), analyses=\(stored.analyses.count)")
            return nil
        }
        
        // Converte análises com verificação de segurança
        let uiAnalyses: [PlantAnalysis] = stored.analyses.compactMap { analysis in
            guard let image = UIImage(data: analysis.photoData) else { 
                print("⚠️ Falha ao converter photoData para UIImage")
                return nil 
            }
            return PlantAnalysis(photo: image, date: analysis.date, notes: analysis.notes)
        }
        
        // Verifica se há pelo menos uma análise válida
        guard let latest = uiAnalyses.last?.photo else { 
            print("⚠️ Nenhuma análise válida encontrada para planta: \(stored.name)")
            return nil 
        }
        
        // Cria a planta com verificação de status
        let plantStatus = stored.status
        var plant = PlantInTreatment(
            name: stored.name, 
            disease: stored.disease, 
            status: plantStatus, 
            photo: latest, 
            treatment: stored.treatment
        )
        
        // Define propriedades adicionais
        plant.id = stored.id
        plant.diagnosisDate = stored.diagnosisDate
        plant.lastUpdate = stored.lastUpdate
        
        // Adiciona análises adicionais
        for analysis in uiAnalyses.dropFirst() { 
            plant.addAnalysis(analysis) 
        }
        
        self = plant
    }
}

extension StoredPlant {
    static func from(_ plant: PlantInTreatment) -> StoredPlant {
        let analyses: [StoredAnalysis] = plant.timeline.map { analysis in
            // Normaliza orientação e reduz tamanho para persistência consistente
            let normalized = analysis.photo.fixOrientation()
            let data = normalized.jpegData(compressionQuality: 0.9) ?? Data()
            return StoredAnalysis(photoData: data, date: analysis.date, notes: analysis.notes)
        }
        return StoredPlant(
            id: plant.id,
            name: plant.name,
            disease: plant.disease,
            statusRaw: plant.status.rawValue,
            diagnosisDate: plant.diagnosisDate,
            lastUpdate: plant.lastUpdate,
            treatment: plant.treatment,
            analyses: analyses
        )
    }
}

// MARK: - UIImage helpers
private extension UIImage {
    func fixOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalized ?? self
    }
}


