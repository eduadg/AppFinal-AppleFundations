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
            
            Text("Enciclopédia View - Em desenvolvimento")
                .tabItem { Image(systemName: "book.pages.fill"); Text("Enciclopédia") }
            
            Text("Perfil View - Em desenvolvimento")
                .tabItem { Image(systemName: "person.crop.circle"); Text("Perfil") }
        }
        .tint(DS.ColorSet.brand)
    }
}

#Preview {
    RootTabView()
        .preferredColorScheme(.light)
}

