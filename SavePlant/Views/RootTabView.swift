import SwiftUI

// MARK: - Tab bar principal
public struct RootTabView: View {
    @EnvironmentObject private var router: AppRouter
    public init() {}
    public var body: some View {
        TabView(selection: $router.selectedTab) {
            HomeView()
                .tag(0)
                .tabItem { Image(systemName: "leaf.fill"); Text("Home") }
            
            HospitalView()
                .tag(1)
                .tabItem { Image(systemName: "cross.case.fill"); Text("Hospital") }
            
            CommunityView()
                .tag(2)
                .tabItem { Image(systemName: "person.3.fill"); Text("Comunidade") }
        }
        .tint(DS.ColorSet.brand)
    }
}

#Preview {
    RootTabView()
}

