import Foundation
import UIKit

// MARK: - Plant Identification Models
public struct PlantIdentificationResult: Codable {
    let suggestions: [PlantSuggestion]?
    let images: [PlantImage]?
    let status: String?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case suggestions
        case images
        case status
        case message
    }
}

public struct PlantSuggestion: Codable {
    let plantName: String
    let plantDetails: PlantDetails?
    let probability: Double
    let similarImages: [SimilarImage]?
    
    enum CodingKeys: String, CodingKey {
        case plantName = "plant_name"
        case plantDetails = "plant_details"
        case probability
        case similarImages = "similar_images"
    }
}

public struct SimilarImage: Codable {
    let id: String
    let url: String
    let similarity: Double
}



public struct PlantImage: Codable {
    let id: String
    let url: String
    let organ: String
    let license: Int
    let citation: String
}

public struct PlantDetails: Codable {
    let commonNames: [String]?
    let scientificName: String?
    let family: String?
    let genus: String?
    let year: Int?
    let bibliography: String?
    let author: String?
    let familyCommonName: String?
    let genusId: Int?
    let mainSpeciesId: Int?
    let mainSpeciesGenus: String?
    let mainSpeciesGenusId: Int?
    let mainSpecies: String?
    let mainSpeciesAuthor: String?
    let subspecies: [String]?
    let variety: [String]?
    let subvariety: [String]?
    let form: [String]?
    let subspecies2: [String]?
    let species: [String]?
    let speciesAggregate: [String]?
    let microspecies: Bool?
    let links: PlantLinks?
    let source: String?
    let curator: String?
    let lastUpdate: String?
    
    enum CodingKeys: String, CodingKey {
        case commonNames = "common_names"
        case scientificName = "scientific_name"
        case family
        case genus
        case year
        case bibliography
        case author
        case familyCommonName = "family_common_name"
        case genusId = "genus_id"
        case mainSpeciesId = "main_species_id"
        case mainSpeciesGenus = "main_species_genus"
        case mainSpeciesGenusId = "main_species_genus_id"
        case mainSpecies = "main_species"
        case mainSpeciesAuthor = "main_species_author"
        case subspecies
        case variety
        case subvariety
        case form
        case subspecies2 = "subspecies2"
        case species
        case speciesAggregate = "species_aggregate"
        case microspecies
        case links
        case source
        case curator
        case lastUpdate = "last_update"
    }
}

public struct PlantLinks: Codable {
    let selfLink: String?
    let plant: String?
    let genus: String?
    
    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case plant
        case genus
    }
}

// MARK: - Plant Identification Service
public class PlantIdentificationService: ObservableObject {
    public static let shared = PlantIdentificationService()
    
    private let apiKey = "bEKhd6HBXL7o18HVtUmjeHKk2THUCVaD5QUbQnIP5TmMcPtard"
    private let baseURL = "https://api.plant.id/v2/identify"
    
    private init() {}
    
    public func identifyPlant(image: UIImage, completion: @escaping (Result<PlantIdentificationResult, Error>) -> Void) {
        // Simular identificação para demonstração (remover quando API estiver funcionando)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let mockResult = self.createMockResult()
            completion(.success(mockResult))
        }
        
        // Implementação real da API (descomentada quando resolver o problema da chave)
        /*
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(PlantIdentificationError.invalidImage))
            return
        }
        
        // Converter imagem para base64
        let base64String = imageData.base64EncodedString()
        
        // Preparar corpo JSON conforme documentação da API Plant.id
        let requestBody: [String: Any] = [
            "images": [base64String],
            "modifiers": ["crops", "similar_images"],
            "plant_details": ["common_names"]
        ]
        
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "Api-Key")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        */
        
        // Comentado para demonstração - descomentar quando API estiver funcionando
        /*
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Verificar status HTTP
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Status: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode != 200 {
                        let errorMessage = "Erro da API: Status \(httpResponse.statusCode)"
                        completion(.failure(PlantIdentificationError.apiError(errorMessage)))
                        return
                    }
                }
                
                guard let data = data else {
                    completion(.failure(PlantIdentificationError.noData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(PlantIdentificationResult.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(PlantIdentificationError.decodingError(error)))
                }
            }
        }.resume()
        */
    }
    
    // MARK: - Mock Data para Demonstração
    private func createMockResult() -> PlantIdentificationResult {
        // Array de plantas possíveis para variedade
        let possiblePlants = [
            ("Limoeiro", "Citrus × limon", "Rutaceae", ["Limoeiro", "Limão"]),
            ("Rosa", "Rosa gallica", "Rosaceae", ["Rosa", "Rosa-vermelha"]),
            ("Manjericão", "Ocimum basilicum", "Lamiaceae", ["Manjericão", "Basilicão"]),
            ("Tomaterio", "Solanum lycopersicum", "Solanaceae", ["Tomate", "Tomateiro"]),
            ("Alecrim", "Rosmarinus officinalis", "Lamiaceae", ["Alecrim", "Rosmarinho"])
        ]
        
        // Selecionar uma planta aleatória
        let randomPlant = possiblePlants.randomElement()!
        
        let plantDetails = PlantDetails(
            commonNames: randomPlant.3,
            scientificName: randomPlant.1,
            family: randomPlant.2,
            genus: randomPlant.1.components(separatedBy: " ").first,
            year: nil,
            bibliography: nil,
            author: nil,
            familyCommonName: "Família \(randomPlant.2)",
            genusId: nil,
            mainSpeciesId: nil,
            mainSpeciesGenus: nil,
            mainSpeciesGenusId: nil,
            mainSpecies: nil,
            mainSpeciesAuthor: nil,
            subspecies: nil,
            variety: nil,
            subvariety: nil,
            form: nil,
            subspecies2: nil,
            species: nil,
            speciesAggregate: nil,
            microspecies: nil,
            links: nil,
            source: nil,
            curator: nil,
            lastUpdate: nil
        )
        
        // Confidence entre 75% e 95%
        let confidence = Double.random(in: 0.75...0.95)
        
        let suggestion = PlantSuggestion(
            plantName: randomPlant.0,
            plantDetails: plantDetails,
            probability: confidence,
            similarImages: nil
        )
        
        return PlantIdentificationResult(
            suggestions: [suggestion],
            images: nil,
            status: "success",
            message: "Identificação realizada com sucesso (simulação)"
        )
    }
}

// MARK: - Plant Identification Errors
public enum PlantIdentificationError: LocalizedError {
    case invalidImage
    case noData
    case decodingError(Error)
    case apiError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Imagem inválida"
        case .noData:
            return "Nenhum dado recebido da API"
        case .decodingError(let error):
            return "Erro ao processar resposta: \(error.localizedDescription)"
        case .apiError(let message):
            return "Erro da API: \(message)"
        }
    }
}

// MARK: - Plant Info Extractor
public struct PlantInfo {
    let name: String
    let scientificName: String?
    let family: String?
    let commonNames: [String]
    let confidence: Double
    
    init(from result: PlantIdentificationResult) {
        // Obter a primeira sugestão com maior probabilidade
        if let firstSuggestion = result.suggestions?.first {
            self.name = firstSuggestion.plantName
            self.confidence = firstSuggestion.probability
            
            if let details = firstSuggestion.plantDetails {
                self.scientificName = details.scientificName
                self.family = details.family
                self.commonNames = details.commonNames ?? []
            } else {
                self.scientificName = nil
                self.family = nil
                self.commonNames = []
            }
        } else {
            self.name = "Planta não identificada"
            self.confidence = 0.0
            self.scientificName = nil
            self.family = nil
            self.commonNames = []
        }
    }
}
