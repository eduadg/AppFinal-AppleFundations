import SwiftUI

// MARK: - Tab bar principal
public struct RootTabView: View {
    public init() {}
    public var body: some View {
        TabView {
            HomeView()
                .tabItem { Image(systemName: "leaf.fill"); Text("Home") }
            
            HospitalView()
                .tabItem { Image(systemName: "cross.case.fill"); Text("Hospital") }
            
            EnciclopediaView()
                .tabItem { Image(systemName: "book.pages.fill"); Text("Enciclopédia") }
        }
        .tint(DS.ColorSet.brand)
    }
}

#Preview {
    RootTabView()
}

