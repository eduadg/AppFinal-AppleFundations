import Foundation

// MARK: - Model do carrossel
public struct QAItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let answers: Int
    public let avatars: [String] // nomes de SF Symbols
}
