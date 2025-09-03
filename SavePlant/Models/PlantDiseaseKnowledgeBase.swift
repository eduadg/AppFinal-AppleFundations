import Foundation

// Base de conhecimento simples: planta → doenças recomendadas (usando CommonDisease já existentes)
enum PlantDiseaseKnowledgeBase {
    // Normaliza texto: minúsculas, remove acentos
    private static func normalize(_ text: String) -> String {
        let folded = text.folding(options: .diacriticInsensitive, locale: .current)
        return folded.lowercased()
    }

    // Atalhos para pegar doenças por nome exato da lista CommonDisease
    private static func disease(named name: String) -> CommonDisease? {
        let key = normalize(name)
        return CommonDisease.commonDiseases.first { normalize($0.name) == key }
    }

    public static func suggestDiseases(for plantName: String) -> [CommonDisease] {
        let name = normalize(plantName)
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }

        // Mapeamentos de palavras‑chave/sinônimos → nomes de doenças
        let tomatoKeywords = ["tomate", "tomato", "solanum lycopersicum"]
        let potatoKeywords = ["batata", "potato", "solanum tuberosum"]
        let roseKeywords   = ["rosa", "rose", "rosa spp"]
        let lemonKeywords  = ["limao", "limão", "citrus", "limoeiro", "lemon"]
        let appleKeywords  = ["maca", "maçã", "apple", "malus domestica"]

        func diseases(_ names: [String]) -> [CommonDisease] {
            names.compactMap { disease(named: $0) }
        }

        // Listas de doenças comuns por cultura (usando nomes presentes em CommonDisease.commonDiseases)
        let tomatoDiseases = diseases(["Míldio", "Oídio", "Mancha Bacteriana", "Vírus do Mosaico"]) 
        let potatoDiseases = diseases(["Míldio", "Mancha Bacteriana", "Ferrugem"]) 
        let roseDiseases   = diseases(["Oídio", "Ferrugem", "Mancha Bacteriana"]) 
        let lemonDiseases  = diseases(["Deficiência Nutricional", "Mancha Bacteriana", "Míldio"]) 
        let appleDiseases  = diseases(["Ferrugem", "Oídio", "Míldio"]) 

        if tomatoKeywords.contains(where: { name.contains($0) }) { return tomatoDiseases }
        if potatoKeywords.contains(where: { name.contains($0) }) { return potatoDiseases }
        if roseKeywords.contains(where: { name.contains($0) })   { return roseDiseases }
        if lemonKeywords.contains(where: { name.contains($0) })  { return lemonDiseases }
        if appleKeywords.contains(where: { name.contains($0) })  { return appleDiseases }

        return []
    }
}


