import SwiftUI

// MARK: - Tab bar principal
public struct RootTabView: View {
    @EnvironmentObject private var router: AppRouter
    public init() {}
    public var body: some View {
        TabView(selection: $router.selectedTab) {
            HomeView()
                .tag(0)
                .tabItem { Image(systemName: "leaf.fill"); Text("Início") }
            
            HospitalView()
                .tag(1)
                .tabItem { Image(systemName: "cross.case.fill"); Text("Hospital") }
            
            EnciclopediaView()
                .tag(2)
                .tabItem { Image(systemName: "book.pages.fill"); Text("Enciclopédia") }
        }
        .tint(DS.ColorSet.brand)
    }
}

// Preview comentado para evitar problemas de compilação
// #Preview {
//     RootTabView()
// }

