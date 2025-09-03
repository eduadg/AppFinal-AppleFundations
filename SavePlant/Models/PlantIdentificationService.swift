import Foundation
import UIKit

// MARK: - Plant Identification Models
public struct PlantIdentificationResult: Codable {
    let result: PlantResult
    let status: String
    let message: String
    
    struct PlantResult: Codable {
        let classification: [PlantClassification]
        let images: [PlantImage]
        let plantDetails: PlantDetails?
        
        enum CodingKeys: String, CodingKey {
            case classification
            case images
            case plantDetails = "plant_details"
        }
    }
}

public struct PlantClassification: Codable {
    let name: String
    let probability: Double
    let similarImages: [String]
    
    enum CodingKeys: String, CodingKey {
        case name
        case probability
        case similarImages = "similar_images"
    }
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
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(PlantIdentificationError.invalidImage))
            return
        }
        
        // Preparar o corpo da requisição
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Api-Key \(apiKey)", forHTTPHeaderField: "Api-Key")
        
        var body = Data()
        
        // Adicionar parâmetros da API
        let parameters = [
            "images": "",
            "organs": "leaf",
            "include_related_images": "true",
            "no_reject": "false",
            "lang": "pt"
        ]
        
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Adicionar a imagem
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"images\"; filename=\"plant.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
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
        if let firstClassification = result.result.classification.first {
            self.name = firstClassification.name
            self.confidence = firstClassification.probability
        } else {
            self.name = "Planta não identificada"
            self.confidence = 0.0
        }
        
        if let details = result.result.plantDetails {
            self.scientificName = details.scientificName
            self.family = details.family
            self.commonNames = details.commonNames ?? []
        } else {
            self.scientificName = nil
            self.family = nil
            self.commonNames = []
        }
    }
}
