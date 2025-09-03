import CoreML
import Vision
import UIKit

struct PlantPrediction {
    let plant: String
    let disease: String
    let confidence: Double
}

final class PlantDiseaseClassifier {
    static let shared = PlantDiseaseClassifier()

    private let vnModel: VNCoreMLModel

    private init?() {
        // A classe é gerada automaticamente pelo .mlmodel (MLPlantSave.mlmodel)
        guard let coreMLModel = try? MLPlantSave(configuration: MLModelConfiguration()).model,
              let vnModel = try? VNCoreMLModel(for: coreMLModel) else { return nil }
        self.vnModel = vnModel
    }

    func classify(_ image: UIImage, completion: @escaping (PlantPrediction?) -> Void) {
        guard let cgImage = image.cgImage else { completion(nil); return }

        let request = VNCoreMLRequest(model: vnModel) { request, _ in
            guard let result = (request.results as? [VNClassificationObservation])?.first else {
                completion(nil); return
            }
            // Ex.: "Tomato___Early_blight" → planta: "Tomato", doença: "Early blight"
            let parts = result.identifier.split(separator: "_")
            let (plant, disease) = Self.splitLabel(parts: parts)

            completion(PlantPrediction(
                plant: plant,
                disease: disease,
                confidence: Double(result.confidence)
            ))
        }
        request.imageCropAndScaleOption = .centerCrop

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }

    private static func splitLabel(parts: [Substring]) -> (String, String) {
        // O dataset costuma usar "___" para separar planta e doença, depois "_" para espaços
        // Aqui juntamos tudo antes do "___" como planta, e o resto como doença.
        let label = parts.map(String.init).joined(separator: "_")
        if let range = label.range(of: "___") {
            let plantRaw   = String(label[..<range.lowerBound])
            let diseaseRaw = String(label[range.upperBound...])
            return (plantRaw.replacingOccurrences(of: "_", with: " "),
                    diseaseRaw.replacingOccurrences(of: "_", with: " "))
        } else {
            // fallback: sem "___" → coloca tudo em doença
            return ("", label.replacingOccurrences(of: "_", with: " "))
        }
    }
}
