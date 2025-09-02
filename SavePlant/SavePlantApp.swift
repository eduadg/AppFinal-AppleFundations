import SwiftUI
import SwiftData

@main
struct SavePlantApp: App {
    @State private var container: ModelContainer = {
        let schema = Schema([StoredPlant.self, StoredAnalysis.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [config])
    }()
    var body: some Scene {
        WindowGroup {
            RootTabView()   // <<< GARANTE que inicia na tela certa
                .onAppear {
                    // Injeta o contexto SwiftData no manager
                    if let context = container.mainContext as ModelContext? {
                        HospitalDataManager.shared.setContext(context)
                    }
                }
        }
        .modelContainer(container)
    }
}

