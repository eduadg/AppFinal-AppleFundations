import Foundation

struct FakePlantRule {
    let plantName: String
    let diseaseName: String
    let note: String
}

enum FakePlantRules {
    static func match(from filename: String) -> FakePlantRule? {
        let name = filename.lowercased()

        // Regras simples por palavra-chave no nome do arquivo
        if name.contains("tomate") || name.contains("tomato") {
            return FakePlantRule(
                plantName: "Tomate",
                diseaseName: "Míldio",
                note: "Auto preenchido por nome do arquivo: \(filename)"
            )
        }
        if name.contains("batata") || name.contains("potato") {
            return FakePlantRule(
                plantName: "Batata",
                diseaseName: "Mancha Bacteriana",
                note: "Auto preenchido por nome do arquivo: \(filename)"
            )
        }
        if name.contains("rosa") || name.contains("rose") {
            return FakePlantRule(
                plantName: "Rosa",
                diseaseName: "Oídio",
                note: "Auto preenchido por nome do arquivo: \(filename)"
            )
        }
        if name.contains("limao") || name.contains("limão") || name.contains("lemon") {
            return FakePlantRule(
                plantName: "Limão",
                diseaseName: "Deficiência Nutricional",
                note: "Auto preenchido por nome do arquivo: \(filename)"
            )
        }
        if name.contains("maca") || name.contains("maçã") || name.contains("apple") {
            return FakePlantRule(
                plantName: "Maçã",
                diseaseName: "Ferrugem",
                note: "Auto preenchido por nome do arquivo: \(filename)"
            )
        }
        return nil
    }
}


