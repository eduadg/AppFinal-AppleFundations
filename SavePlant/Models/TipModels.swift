import Foundation

public struct TipItem {
    public let title: String
    public let description: String
    public let icon: String
    
    public init(title: String, description: String, icon: String) {
        self.title = title
        self.description = description
        self.icon = icon
    }
}
