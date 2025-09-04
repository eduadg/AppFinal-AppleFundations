import Foundation
import UIKit

// MARK: - Community Models

public enum PostType: String, CaseIterable {
    case treatment = "Tratamento"
    case tip = "Dica"
    case question = "Pergunta"
    case success = "Sucesso"
    case photo = "Foto"
    
    var iconName: String {
        switch self {
        case .treatment:
            return "cross.case.fill"
        case .tip:
            return "lightbulb.fill"
        case .question:
            return "questionmark.circle.fill"
        case .success:
            return "checkmark.seal.fill"
        case .photo:
            return "photo.fill"
        }
    }
    
    var color: UIColor {
        switch self {
        case .treatment:
            return UIColor.systemRed
        case .tip:
            return UIColor.systemYellow
        case .question:
            return UIColor.systemBlue
        case .success:
            return UIColor.systemGreen
        case .photo:
            return UIColor.systemPurple
        }
    }
}

public struct CommunityUser: Identifiable, Hashable {
    public let id = UUID()
    public let name: String
    public let avatar: String // SF Symbol name
    public let location: String
    public let joinDate: Date
    public let plantsCount: Int
    public let postsCount: Int
    
    public init(name: String, avatar: String, location: String, joinDate: Date = Date(), plantsCount: Int, postsCount: Int) {
        self.name = name
        self.avatar = avatar
        self.location = location
        self.joinDate = joinDate
        self.plantsCount = plantsCount
        self.postsCount = postsCount
    }
    
    public var formattedJoinDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: joinDate)
    }
}

public struct CommunityPost: Identifiable, Hashable {
    public let id = UUID()
    public let user: CommunityUser
    public let type: PostType
    public let title: String
    public let content: String
    public let plantName: String?
    public let plantDisease: String?
    public let imageData: Data?
    public let date: Date
    public let likes: Int
    public let comments: Int
    public let isLiked: Bool
    public let tags: [String]
    
    public init(
        user: CommunityUser,
        type: PostType,
        title: String,
        content: String,
        plantName: String? = nil,
        plantDisease: String? = nil,
        imageData: Data? = nil,
        date: Date = Date(),
        likes: Int = 0,
        comments: Int = 0,
        isLiked: Bool = false,
        tags: [String] = []
    ) {
        self.user = user
        self.type = type
        self.title = title
        self.content = content
        self.plantName = plantName
        self.plantDisease = plantDisease
        self.imageData = imageData
        self.date = date
        self.likes = likes
        self.comments = comments
        self.isLiked = isLiked
        self.tags = tags
    }
    
    public var image: UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }
    
    public var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

public struct CommunityComment: Identifiable, Hashable {
    public let id = UUID()
    public let user: CommunityUser
    public let content: String
    public let date: Date
    public let likes: Int
    
    public init(user: CommunityUser, content: String, date: Date = Date(), likes: Int = 0) {
        self.user = user
        self.content = content
        self.date = date
        self.likes = likes
    }
    
    public var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Community Data Manager
public class CommunityDataManager: ObservableObject {
    @Published public var posts: [CommunityPost] = []
    @Published public var users: [CommunityUser] = []
    @Published public var trendingPosts: [CommunityPost] = []
    
    public static let shared = CommunityDataManager()
    
    private init() {
        loadMockData()
    }
    
    public func likePost(_ post: CommunityPost) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            // Como CommunityPost é struct, precisaríamos de uma abordagem diferente
            // Por enquanto, vamos manter o likes como está
        }
    }
    
    public func getPostsByType(_ type: PostType) -> [CommunityPost] {
        return posts.filter { $0.type == type }
    }
    
    public func searchPosts(_ query: String) -> [CommunityPost] {
        let lowercasedQuery = query.lowercased()
        return posts.filter { post in
            post.title.lowercased().contains(lowercasedQuery) ||
            post.content.lowercased().contains(lowercasedQuery) ||
            post.plantName?.lowercased().contains(lowercasedQuery) == true ||
            post.tags.contains { $0.lowercased().contains(lowercasedQuery) }
        }
    }
    
    private func loadMockData() {
        // Mock Users
        users = [
            CommunityUser(name: "Maria Silva", avatar: "person.circle.fill", location: "São Paulo, SP", plantsCount: 12, postsCount: 8),
            CommunityUser(name: "João Santos", avatar: "person.crop.circle.fill", location: "Rio de Janeiro, RJ", plantsCount: 8, postsCount: 15),
            CommunityUser(name: "Ana Costa", avatar: "person.badge.plus", location: "Belo Horizonte, MG", plantsCount: 20, postsCount: 23),
            CommunityUser(name: "Pedro Oliveira", avatar: "person.crop.rectangle", location: "Porto Alegre, RS", plantsCount: 6, postsCount: 12),
            CommunityUser(name: "Lucia Ferreira", avatar: "person.crop.square", location: "Salvador, BA", plantsCount: 15, postsCount: 19)
        ]
        
        // Mock Posts
        posts = [
            // Tratamentos
            CommunityPost(
                user: users[0],
                type: .treatment,
                title: "Como salvei minha rosa do oídio",
                content: "Minha rosa estava com oídio e consegui salvá-la usando uma mistura caseira de bicarbonato de sódio e óleo de neem. Apliquei por 2 semanas e ela se recuperou completamente!",
                plantName: "Rosa",
                plantDisease: "Oídio",
                likes: 24,
                comments: 8,
                tags: ["rosa", "oídio", "tratamento caseiro", "bicarbonato"]
            ),
            
            CommunityPost(
                user: users[1],
                type: .treatment,
                title: "Tratamento do míldio no tomate",
                content: "Usei calda bordalesa para tratar o míldio no meu tomateiro. Apliquei a cada 7 dias e melhorei a ventilação. Resultado: plantas saudáveis e muitos tomates!",
                plantName: "Tomate",
                plantDisease: "Míldio",
                likes: 31,
                comments: 12,
                tags: ["tomate", "míldio", "calda bordalesa", "ventilação"]
            ),
            
            // Dicas
            CommunityPost(
                user: users[2],
                type: .tip,
                title: "Dica para regar suculentas",
                content: "Sempre rego minhas suculentas pela manhã e deixo o solo secar completamente entre as regas. Elas adoram sol direto e pouca água!",
                plantName: "Suculentas",
                likes: 45,
                comments: 15,
                tags: ["suculentas", "rega", "sol", "drenagem"]
            ),
            
            CommunityPost(
                user: users[3],
                type: .tip,
                title: "Como fazer mudas de manjericão",
                content: "Corte um galho de 10cm, remova as folhas inferiores e coloque na água. Em 1 semana aparecem raízes. Depois é só plantar no solo!",
                plantName: "Manjericão",
                likes: 38,
                comments: 9,
                tags: ["manjericão", "mudas", "propagação", "água"]
            ),
            
            // Perguntas
            CommunityPost(
                user: users[4],
                type: .question,
                title: "Minha orquídea não floresce",
                content: "Tenho uma orquídea Phalaenopsis há 2 anos e ela não floresce. Está em local bem iluminado e rego quando o substrato seca. O que posso fazer?",
                plantName: "Orquídea",
                likes: 12,
                comments: 23,
                tags: ["orquídea", "floração", "phalaenopsis", "cuidados"]
            ),
            
            CommunityPost(
                user: users[0],
                type: .question,
                title: "Folhas amarelas no limão",
                content: "Meu pé de limão está com as folhas amarelando. É normal ou tem algum problema?",
                plantName: "Limão",
                likes: 8,
                comments: 16,
                tags: ["limão", "folhas amarelas", "diagnóstico", "citros"]
            ),
            
            // Sucessos
            CommunityPost(
                user: users[1],
                type: .success,
                title: "Primeira colheita de alface",
                content: "Plantei alface em vasos na varanda e hoje fiz minha primeira colheita! Orgânica e fresquinha. Valeu muito a pena!",
                plantName: "Alface",
                likes: 52,
                comments: 18,
                tags: ["alface", "colheita", "varanda", "orgânico"]
            ),
            
            CommunityPost(
                user: users[2],
                type: .success,
                title: "Suculenta que renasceu",
                content: "Minha suculenta estava quase morta, mas com muito carinho e os cuidados certos ela renasceu! Agora está linda e cheia de vida.",
                plantName: "Suculenta",
                likes: 67,
                comments: 25,
                tags: ["suculenta", "recuperação", "cuidados", "renascimento"]
            ),
            
            // Fotos
            CommunityPost(
                user: users[3],
                type: .photo,
                title: "Minha horta urbana",
                content: "Compartilhando minha pequena horta urbana na sacada. Tomates, pimentões, ervas e flores. Cada planta tem uma história!",
                plantName: "Horta urbana",
                likes: 89,
                comments: 31,
                tags: ["horta urbana", "sacada", "tomates", "pimentões", "ervas"]
            ),
            
            CommunityPost(
                user: users[4],
                type: .photo,
                title: "Jardim de inverno",
                content: "Criei um cantinho especial para minhas plantas no inverno. Elas adoram a luz filtrada e a temperatura amena!",
                plantName: "Jardim de inverno",
                likes: 76,
                comments: 28,
                tags: ["jardim de inverno", "luz filtrada", "temperatura", "cantinho especial"]
            )
        ]
        
        updateTrendingPosts()
    }
    
    private func updateTrendingPosts() {
        trendingPosts = Array(posts.sorted { first, second in
            if first.likes != second.likes {
                return first.likes > second.likes
            }
            return first.comments > second.comments
        }.prefix(5))
    }
}
