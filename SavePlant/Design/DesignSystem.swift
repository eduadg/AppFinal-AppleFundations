import SwiftUI

// MARK: - Design System centralizado
public enum DS {
    public enum Spacing {
        public static let xs: CGFloat = 6
        public static let sm: CGFloat = 10
        public static let md: CGFloat = 16
        public static let lg: CGFloat = 20
        public static let xl: CGFloat = 24
    }
    public enum Radius {
        public static let sm: CGFloat = 12
        public static let md: CGFloat = 18
        public static let lg: CGFloat = 24
        public static let pill: CGFloat = 999
    }
    public enum Shadow {
        public static let soft = Color.black.opacity(0.07)
    }
    public enum ColorSet {
        public static let brand = Color(red: 0.10, green: 0.33, blue: 0.26)
        public static let brandMuted = Color(red: 0.77, green: 0.87, blue: 0.82)
        public static let surface = Color(.systemBackground)
        public static let textPrimary = Color.primary
        public static let textSecondary = Color.secondary
    }
}

