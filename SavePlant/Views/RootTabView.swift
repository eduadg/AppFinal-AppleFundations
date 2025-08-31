import SwiftUI

// MARK: - Tab bar principal
public struct RootTabView: View {
    public init() {}
    public var body: some View {
        TabView {
            HomeView()
                .tabItem { Image(systemName: "house.fill"); Text("Home") }
            
            Text("Favorites")
                .tabItem { Image(systemName: "heart.fill"); Text("Favorites") }
            
            ScanView()
                .tabItem { Image(systemName: "viewfinder"); Text("Scan") }
            
            Text("Community")
                .tabItem { Image(systemName: "bubble.left.and.bubble.right.fill"); Text("Community") }
            
            Text("Profile")
                .tabItem { Image(systemName: "person.fill"); Text("Profile") }
        }
        .tint(DS.ColorSet.brand)
    }
}

#Preview {
    RootTabView()
        .preferredColorScheme(.light)
}

