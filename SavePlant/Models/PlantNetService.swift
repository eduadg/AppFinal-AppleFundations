import Foundation
import UIKit

// MARK: - PlantNet API Models (mínimos necessários)
private struct PlantNetResponse: Codable {
    let results: [PlantNetResult]?
}

private struct PlantNetResult: Codable {
    let score: Double?
    let species: PlantNetSpecies?
}

private struct PlantNetSpecies: Codable {
    let scientificNameWithoutAuthor: String?
    let scientificNameAuthorship: String?
    let genus: PlantNetTaxon?
    let family: PlantNetTaxon?
    let commonNames: [String]?
}

private struct PlantNetTaxon: Codable {
    let scientificNameWithoutAuthor: String?
}

// MARK: - Serviço PlantNet
public final class PlantNetService: ObservableObject {
    public static let shared = PlantNetService()

    // Preencha com sua chave da PlantNet. Requer cadastro em my.plantnet.org
    // Se vazio, o serviço usará um fallback local (mock) para não quebrar o fluxo.
    private let apiKey: String = "" // TODO: inserir chave PlantNet aqui
    private let baseURL: String = "https://my-api.plantnet.org/v2/identify/all"

    private init() {}

    public func identifyPlant(image: UIImage, completion: @escaping (Result<PlantInfo, Error>) -> Void) {
        // Se a chave não estiver configurada, retorna mock para demonstração
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(.success(self.createMockInfo()))
            return
        }

        guard let imageData = image.jpegData(compressionQuality: 0.85) else {
            completion(.failure(PlantIdentificationError.invalidImage))
            return
        }

        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "api-key", value: apiKey)
        ]

        guard let url = components.url else {
            completion(.failure(PlantIdentificationError.apiError("URL inválida")))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // multipart/form-data
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Campo organs (opcional, ajuda o modelo)
        appendFormField(name: "organs", value: "leaf", boundary: boundary, to: &body)

        // Campo de imagem
        appendFileField(name: "images", filename: "photo.jpg", mimeType: "image/jpeg", fileData: imageData, boundary: boundary, to: &body)

        // Encerrar body
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                    completion(.failure(PlantIdentificationError.apiError("PlantNet HTTP \(http.statusCode)")))
                    return
                }

                guard let data = data else {
                    completion(.failure(PlantIdentificationError.noData))
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(PlantNetResponse.self, from: data)
                    if let info = self.mapToPlantInfo(decoded) {
                        completion(.success(info))
                    } else {
                        completion(.failure(PlantIdentificationError.apiError("Resposta vazia da PlantNet")))
                    }
                } catch {
                    completion(.failure(PlantIdentificationError.decodingError(error)))
                }
            }
        }.resume()
    }

    // MARK: - Helpers
    private func mapToPlantInfo(_ response: PlantNetResponse) -> PlantInfo? {
        guard let first = response.results?.first, let species = first.species else { return nil }

        let name: String = {
            if let common = species.commonNames?.first, !common.isEmpty { return common }
            return species.scientificNameWithoutAuthor ?? "Planta"
        }()

        let scientific = species.scientificNameWithoutAuthor
        let family = species.family?.scientificNameWithoutAuthor
        let commons = species.commonNames ?? []
        let confidence = first.score ?? 0

        return PlantInfo(name: name, scientificName: scientific, family: family, commonNames: commons, confidence: confidence)
    }

    private func createMockInfo() -> PlantInfo {
        // Fallback simples para quando a chave não está configurada
        return PlantInfo(name: "Manjericão", scientificName: "Ocimum basilicum", family: "Lamiaceae", commonNames: ["Manjericão", "Basil"], confidence: 0.9)
    }
}

// MARK: - Multipart helpers
private func appendFormField(name: String, value: String, boundary: String, to data: inout Data) {
    data.append("--\(boundary)\r\n".data(using: .utf8)!)
    data.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
    data.append("\(value)\r\n".data(using: .utf8)!)
}

private func appendFileField(name: String, filename: String, mimeType: String, fileData: Data, boundary: String, to data: inout Data) {
    data.append("--\(boundary)\r\n".data(using: .utf8)!)
    data.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
    data.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
    data.append(fileData)
    data.append("\r\n".data(using: .utf8)!)
}


