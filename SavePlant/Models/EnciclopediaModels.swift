import Foundation
import SwiftUI

// MARK: - Enciclopedia Post
public struct EnciclopediaPost: Identifiable, Codable {
    public let id = UUID()
    public let title: String
    public let content: String
    public let author: String
    public let date: Date
    public let category: PostCategory
    public let tags: [String]
    public let imageURL: String?
    public let relatedPlantIds: [UUID] // IDs das plantas do hospital relacionadas
    public let likes: Int
    public let isFeatured: Bool
    
    public init(
        title: String,
        content: String,
        author: String,
        category: PostCategory,
        tags: [String] = [],
        imageURL: String? = nil,
        relatedPlantIds: [UUID] = [],
        likes: Int = 0,
        isFeatured: Bool = false
    ) {
        self.title = title
        self.content = content
        self.author = author
        self.date = Date()
        self.category = category
        self.tags = tags
        self.imageURL = imageURL
        self.relatedPlantIds = relatedPlantIds
        self.likes = likes
        self.isFeatured = isFeatured
    }
}

// MARK: - Post Categories
public enum PostCategory: String, CaseIterable, Codable {
    case curiosidades = "Curiosidades"
    case dicas = "Dicas de Cultivo"
    case tratamentos = "Tratamentos"
    case identificacao = "Identificação"
    case prevencao = "Prevenção"
    case historias = "Histórias de Sucesso"
    
    var icon: String {
        switch self {
        case .curiosidades: return "lightbulb.fill"
        case .dicas: return "leaf.fill"
        case .tratamentos: return "cross.case.fill"
        case .identificacao: return "magnifyingglass"
        case .prevencao: return "shield.fill"
        case .historias: return "star.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .curiosidades: return Color.orange
        case .dicas: return Color.green
        case .tratamentos: return Color.red
        case .identificacao: return Color.blue
        case .prevencao: return Color.purple
        case .historias: return Color.yellow
        }
    }
}

// MARK: - Enciclopedia Data Manager
public class EnciclopediaDataManager: ObservableObject {
    public static let shared = EnciclopediaDataManager()
    
    @Published public var posts: [EnciclopediaPost] = []
    @Published public var filteredPosts: [EnciclopediaPost] = []
    @Published public var selectedCategory: PostCategory?
    @Published public var searchText: String = ""
    
    private init() {
        loadMockData()
    }
    
    // MARK: - Mock Data
    private func loadMockData() {
        posts = [
            // Curiosidades
            EnciclopediaPost(
                title: "Por que as plantas 'dormem' à noite?",
                content: "As plantas realizam um processo chamado 'movimento nictinástico', onde suas folhas se movem em resposta à luz. À noite, muitas plantas dobram suas folhas para conservar energia e reduzir a perda de água. Este comportamento é controlado por um relógio biológico interno chamado ritmo circadiano, similar ao que acontece com os humanos.\n\nAlgumas plantas, como a Mimosa pudica (planta sensitiva), são conhecidas por fechar suas folhas ao toque, um mecanismo de defesa contra herbívoros.",
                author: "Dr. Botânico Silva",
                category: .curiosidades,
                tags: ["fisiologia", "ritmo circadiano", "movimento nictinástico"],
                likes: 42,
                isFeatured: true
            ),
            
            // Dicas de Cultivo
            EnciclopediaPost(
                title: "5 Dicas Essenciais para Tomates Perfeitos",
                content: "1. **Solo Rico**: Use solo bem drenado com pH entre 6.0-6.8\n2. **Luz Solar**: Mínimo 6-8 horas de sol direto por dia\n3. **Rega Consistente**: Mantenha o solo úmido, mas não encharcado\n4. **Suporte Adequado**: Use estacas ou gaiolas para evitar quebra\n5. **Poda Regular**: Remova brotos laterais para focar energia nos frutos\n\n**Dica Extra**: Plante manjericão próximo aos tomates - eles se beneficiam mutuamente!",
                author: "Maria Jardineira",
                category: .dicas,
                tags: ["tomate", "cultivo", "horta", "dicas"],
                likes: 67,
                isFeatured: true
            ),
            
            // Tratamentos
            EnciclopediaPost(
                title: "Míldio: O Inimigo Silencioso das Plantas",
                content: "O míldio é uma das doenças mais devastadoras para plantas, causada por fungos do gênero Peronospora. Ele se espalha rapidamente em condições úmidas e pode destruir plantações inteiras em poucos dias.\n\n**Sintomas**:\n• Manchas amarelas nas folhas\n• Crescimento branco na parte inferior\n• Folhas murchas e caídas\n\n**Tratamento Eficaz**:\n• Fungicida à base de cobre\n• Reduzir umidade\n• Melhorar ventilação\n• Remover folhas infectadas\n\n**Prevenção**:\n• Evitar rega nas folhas\n• Espaçamento adequado entre plantas\n• Rotação de culturas",
                author: "Prof. Fitopatologia Costa",
                category: .tratamentos,
                tags: ["míldio", "fungo", "doença", "tratamento"],
                likes: 89,
                isFeatured: true
            ),
            
            // Identificação
            EnciclopediaPost(
                title: "Como Identificar Doenças por Sintomas Visuais",
                content: "A identificação precoce de doenças é crucial para o sucesso do tratamento. Aqui está um guia visual:\n\n**Manchas nas Folhas**:\n• Marrons/pretas = Bactérias\n• Amarelas = Fungos ou vírus\n• Brancas = Oídio\n\n**Mudanças de Cor**:\n• Amarelamento = Deficiência nutricional\n• Escurecimento = Podridão\n• Manchas circulares = Fungos\n\n**Deformações**:\n• Folhas enroladas = Vírus\n• Crescimento atrofiado = Nematoides\n• Galhas = Bactérias\n\n**Dica**: Sempre fotografe os sintomas para acompanhar a evolução!",
                author: "Dra. Diagnóstico Verde",
                category: .identificacao,
                tags: ["identificação", "sintomas", "diagnóstico", "visual"],
                likes: 156,
                isFeatured: true
            ),
            
            // Prevenção
            EnciclopediaPost(
                title: "Prevenção é Melhor que Cura: Guia Completo",
                content: "A prevenção de doenças nas plantas é fundamental para manter um jardim saudável. Aqui estão as estratégias mais eficazes:\n\n**1. Higiene do Jardim**:\n• Limpe ferramentas entre usos\n• Remova detritos e folhas caídas\n• Desinfete vasos reutilizados\n\n**2. Rotação de Culturas**:\n• Mude a localização das plantas anualmente\n• Evite plantar a mesma família no mesmo local\n• Use plantas companheiras\n\n**3. Condições Ideais**:\n• Solo bem drenado\n• Espaçamento adequado\n• Ventilação entre plantas\n\n**4. Monitoramento Regular**:\n• Inspeção semanal das plantas\n• Registro de mudanças\n• Ação imediata ao detectar problemas",
                author: "Eng. Agronômico Santos",
                category: .prevencao,
                tags: ["prevenção", "higiene", "rotação", "monitoramento"],
                likes: 203,
                isFeatured: true
            ),
            
            // Histórias de Sucesso
            EnciclopediaPost(
                title: "Do Desespero à Cura: Minha Rosa Recuperada",
                content: "Há 3 meses, minha rosa favorita estava à beira da morte. As folhas estavam cobertas de oídio e ela mal conseguia florescer. Desesperada, decidi tentar uma abordagem diferente.\n\n**O que funcionou**:\n• Tratamento com bicarbonato de sódio (1 colher + 1L água)\n• Aplicação de óleo de neem\n• Melhoria na ventilação\n• Redução da umidade\n\n**Resultado**: Em 6 semanas, a rosa estava completamente recuperada e florescendo como nunca antes!\n\n**Lições aprendidas**:\n• Paciência é fundamental\n• Tratamentos naturais podem ser muito eficazes\n• Prevenção é sempre melhor\n\nEspero que minha experiência ajude outros jardineiros!",
                author: "Ana Rosa",
                category: .historias,
                tags: ["rosa", "oídio", "recuperação", "tratamento natural", "sucesso"],
                likes: 78,
                isFeatured: false
            ),
            
            // Mais posts...
            EnciclopediaPost(
                title: "Fertilizantes Naturais: Receitas Caseiras",
                content: "Descubra como criar fertilizantes naturais e baratos para suas plantas:\n\n**Chá de Banana**:\n• Cascas de banana + água\n• Deixe fermentar por 3 dias\n• Dilua 1:5 para aplicar\n\n**Casca de Ovo**:\n• Triture cascas secas\n• Polvilhe no solo\n• Rico em cálcio\n\n**Borras de Café**:\n• Espalhe no solo\n• Excelente para plantas ácidas\n• Melhora a textura do solo",
                author: "João Orgânico",
                category: .dicas,
                tags: ["fertilizante", "natural", "caseiro", "orgânico"],
                likes: 45
            ),
            
            EnciclopediaPost(
                title: "Pragas Comuns e Como Combatê-las",
                content: "Guia rápido para identificar e combater as pragas mais comuns:\n\n**Pulgões**:\n• Sintoma: Folhas enroladas, melada\n• Controle: Água com sabão, joaninhas\n\n**Cochonilhas**:\n• Sintoma: Manchas brancas, crescimento atrofiado\n• Controle: Álcool isopropílico, óleo de neem\n\n**Ácaros**:\n• Sintoma: Teias finas, manchas amarelas\n• Controle: Água pressurizada, sabão inseticida",
                author: "Técnico Agrícola Lima",
                category: .tratamentos,
                tags: ["pragas", "controle", "insetos", "combate"],
                likes: 92
            )
        ]
        
        filteredPosts = posts
    }
    
    // MARK: - Filtering
    public func filterPosts() {
        var filtered = posts
        
        // Filter by category
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { post in
                post.title.localizedCaseInsensitiveContains(searchText) ||
                post.content.localizedCaseInsensitiveContains(searchText) ||
                post.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        filteredPosts = filtered
    }
    
    // MARK: - Post Management
    public func addPost(_ post: EnciclopediaPost) {
        posts.insert(post, at: 0)
        filterPosts()
    }
    
    public func likePost(_ postId: UUID) {
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            posts[index] = EnciclopediaPost(
                title: posts[index].title,
                content: posts[index].content,
                author: posts[index].author,
                category: posts[index].category,
                tags: posts[index].tags,
                imageURL: posts[index].imageURL,
                relatedPlantIds: posts[index].relatedPlantIds,
                likes: posts[index].likes + 1,
                isFeatured: posts[index].isFeatured
            )
            filterPosts()
        }
    }
    
    public func getPostsByPlantId(_ plantId: UUID) -> [EnciclopediaPost] {
        return posts.filter { $0.relatedPlantIds.contains(plantId) }
    }
}
