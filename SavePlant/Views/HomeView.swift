import SwiftUI

public struct HomeView: View {
    @State private var search = ""
    @State private var isSearching = false
    @State private var searchResults: [PlantInTreatment] = []
    // showingScanView removido - não é mais necessário
    @EnvironmentObject private var router: AppRouter
    @StateObject private var hospitalData = HospitalDataManager.shared

    private let tipsData: [TipItem] = [
        .init(title: "Evite molhar folhas à noite", description: "A umidade noturna favorece o desenvolvimento de fungos", icon: "moon.stars.fill"),
        .init(title: "Podar partes doentes", description: "Remova folhas e galhos infectados para evitar propagação", icon: "scissors"),
        .init(title: "Rotacione culturas", description: "Alterne os tipos de plantas para manter o solo saudável", icon: "arrow.triangle.2.circlepath"),
        .init(title: "Use água morna", description: "Água muito fria pode causar choque térmico nas raízes", icon: "thermometer"),
        .init(title: "Adube na primavera", description: "Época ideal para fornecer nutrientes essenciais", icon: "leaf.fill"),
        .init(title: "Mantenha distância", description: "Evite aglomeração de plantas para melhor circulação de ar", icon: "arrow.left.and.right"),
        .init(title: "Limpe as ferramentas", description: "Desinfete tesouras e pás entre usos", icon: "sparkles"),
        .init(title: "Observe as folhas", description: "Mudanças de cor podem indicar problemas nutricionais", icon: "eye.fill")
    ]

    public init() {}

    public var body: some View {
        ZStack {
            // Fundo moderno com cores mais equilibradas
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.99, blue: 0.98), // Branco quase puro
                    Color(red: 0.94, green: 0.97, blue: 0.95), // Verde muito sutil
                    Color(red: 0.92, green: 0.95, blue: 0.93)  // Verde ultra suave
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Textura mais sutil e moderna
            GeometryReader { geometry in
                ForEach(0..<12, id: \.self) { _ in
                    Circle()
                        .fill(Color(red: 0.85, green: 0.92, blue: 0.88).opacity(0.08))
                        .frame(width: CGFloat.random(in: 4...12))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header customizado
                HStack {
                    Text("PlantSave")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(DS.ColorSet.textPrimary)
                    
                    Spacer()
                    
                    // Ícone do perfil
                    Circle()
                        .fill(DS.ColorSet.brandMuted)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(DS.ColorSet.brand)
                                .font(.system(size: 16, weight: .bold))
                        )
                        .accessibilityLabel(Text("Profile"))
                }
                .padding(EdgeInsets(top: DS.Spacing.sm, leading: DS.Spacing.md, bottom: DS.Spacing.xs, trailing: DS.Spacing.md))
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: DS.Spacing.lg) {

                        // Search Bar com funcionalidade de busca
                        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                            Text("Buscar Planta")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(DS.ColorSet.textPrimary)
                            
                            SearchBar(
                                text: $search, 
                                placeholder: "Digite o nome da planta ou doença...",
                                onSearch: performSearch
                            )
                        }
                        .padding(EdgeInsets(top: DS.Spacing.md, leading: 0, bottom: 0, trailing: 0))

                        // Resultados da busca
                        if isSearching && !searchResults.isEmpty {
                            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                                Text("Resultados da Busca")
                                    .font(.title3.weight(.semibold))
                                    .foregroundColor(DS.ColorSet.textPrimary)
                                
                                LazyVStack(spacing: DS.Spacing.sm) {
                                    ForEach(searchResults, id: \.id) { plant in
                                        PlantSearchResultCard(plant: plant) {
                                            // Navega para o hospital e seleciona a planta
                                            router.selectedTab = 1
                                            // Aqui você pode implementar a seleção da planta específica
                                        }
                                    }
                                }
                            }
                        } else if isSearching && search.isEmpty {
                            // Mostra todas as plantas quando não há busca
                            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                                Text("Suas Plantas")
                                    .font(.title3.weight(.semibold))
                                    .foregroundColor(DS.ColorSet.textPrimary)
                                
                                if hospitalData.plantsInTreatment.isEmpty {
                                    Text("Nenhuma planta cadastrada ainda")
                                        .font(.body)
                                        .foregroundColor(DS.ColorSet.textSecondary)
                                        .padding(.vertical, DS.Spacing.lg)
                                } else {
                                    LazyVStack(spacing: DS.Spacing.sm) {
                                        ForEach(hospitalData.plantsInTreatment, id: \.id) { plant in
                                            PlantSearchResultCard(plant: plant) {
                                                router.selectedTab = 1
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Layout dos 3 cards principais (só mostra quando não está buscando)
                        if !isSearching {
                            VStack(spacing: DS.Spacing.md) {
                                // Card A - Diagnosticar agora (largura total)
                                Button(action: {
                                    // Vai direto para o Hospital (tab 1) e abre modal de adicionar planta
                                    router.selectedTab = 1
                                    // Pequeno delay para garantir que a tab mudou antes de abrir o modal
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        NotificationCenter.default.post(name: .showAddPlantModal, object: nil)
                                    }
                                }) {
                                    HStack {
                                        Spacer()
                                        Image(systemName: "camera.viewfinder")
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.white)
                                            .offset(y: -8) // Subindo o ícone um pouco
                                    }
                                    .padding(EdgeInsets(top: DS.Spacing.md, leading: 0, bottom: 0, trailing: DS.Spacing.md))
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Diagnosticar")
                                            .font(.headline.weight(.bold))
                                            .foregroundColor(.white)
                                        Text("Use a câmera para analisar")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(EdgeInsets(top: 0, leading: DS.Spacing.md, bottom: DS.Spacing.md, trailing: DS.Spacing.md))
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(
                                    ZStack {
                                        // Imagem de fundo
                                        if let doencasImage = UIImage(named: "Doenças") {
                                            Image(uiImage: doencasImage)
                                                .resizable()
                                                .scaledToFill()
                                        } else {
                                            // Fallback gradient
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.25, green: 0.40, blue: 0.32),
                                                    Color(red: 0.15, green: 0.35, blue: 0.28)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        }
                                        
                                        // Overlay para melhorar legibilidade do texto
                                        LinearGradient(
                                            colors: [.clear, .clear, .black.opacity(0.4)],
                                            startPoint: .top, 
                                            endPoint: .bottom
                                        )
                                    }
                                )
                                .cornerRadius(20)
                                .clipped()
                                .frame(height: 160)
                                .buttonStyle(PlainButtonStyle())
                                
                                // Cards B e C lado a lado
                                HStack(spacing: DS.Spacing.md) {
                                    // Card B - Hospital
                                    Button(action: {
                                        router.selectedTab = 1
                                    }) {
                                        VStack {
                                            HStack {
                                                Spacer()
                                                Image(systemName: "cross.case.fill")
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                            .padding(EdgeInsets(top: DS.Spacing.md, leading: 0, bottom: 0, trailing: DS.Spacing.md))
                                            
                                            Spacer()
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Hospital")
                                                    .font(.headline.weight(.bold))
                                                    .foregroundColor(.white)
                                                let plantsInTreatment = hospitalData.plantsInTreatment.filter { $0.status == .inTreatment }.count
                                                Text("\(plantsInTreatment) em tratamento")
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.8))
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(EdgeInsets(top: 0, leading: DS.Spacing.md, bottom: DS.Spacing.md, trailing: DS.Spacing.md))
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background(
                                            ZStack {
                                                // Imagem de fundo
                                                if let hospitalImage = UIImage(named: "hospital") {
                                                    Image(uiImage: hospitalImage)
                                                        .resizable()
                                                        .scaledToFill()
                                                } else {
                                                    // Fallback gradient
                                                    LinearGradient(
                                                        colors: [
                                                            Color(red: 0.45, green: 0.63, blue: 0.55),
                                                            Color(red: 0.18, green: 0.43, blue: 0.34)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                }
                                                
                                                // Overlay para melhorar legibilidade do texto
                                                LinearGradient(
                                                    colors: [.clear, .clear, .black.opacity(0.4)],
                                                    startPoint: .top, 
                                                    endPoint: .bottom
                                                )
                                            }
                                        )
                                        .cornerRadius(20)
                                        .clipped()
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    // Card C - Enciclopédia
                                    Button(action: {
                                        // Vai para a Enciclopédia (tab 2)
                                        router.selectedTab = 2
                                    }) {
                                        VStack {
                                            HStack {
                                                Spacer()
                                                Image(systemName: "book.pages.fill")
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                            .padding(EdgeInsets(top: DS.Spacing.md, leading: 0, bottom: 0, trailing: DS.Spacing.md))
                                            
                                            Spacer()
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Enciclopédia")
                                                    .font(.headline.weight(.bold))
                                                    .foregroundColor(.white)
                                                Text("Doenças & Tratamentos")
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.8))
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(EdgeInsets(top: 0, leading: DS.Spacing.md, bottom: DS.Spacing.md, trailing: DS.Spacing.md))
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background(
                                            ZStack {
                                                // Imagem de fundo
                                                if let enciclopediaImage = UIImage(named: "enciclopedia") {
                                                    Image(uiImage: enciclopediaImage)
                                                        .resizable()
                                                        .scaledToFill()
                                                } else {
                                                    // Fallback gradient
                                                    LinearGradient(
                                                        colors: [
                                                            Color(red: 0.70, green: 0.82, blue: 0.76),
                                                            Color(red: 0.32, green: 0.55, blue: 0.46)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                }
                                                
                                                // Overlay para melhorar legibilidade do texto
                                                LinearGradient(
                                                    colors: [.clear, .clear, .black.opacity(0.4)],
                                                    startPoint: .top, 
                                                    endPoint: .bottom
                                                )
                                            }
                                        )
                                        .cornerRadius(20)
                                        .clipped()
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .frame(height: 140)
                            }

                            Text("Dicas da Comunidade")
                                .font(.title3.weight(.semibold))
                                .foregroundColor(DS.ColorSet.textPrimary)
                                .padding(EdgeInsets(top: DS.Spacing.sm, leading: DS.Spacing.xl, bottom: 0, trailing: DS.Spacing.xl))

                            TipsCarousel(items: tipsData)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: DS.Spacing.md, trailing: 0))
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: DS.Spacing.md, bottom: DS.Spacing.lg, trailing: DS.Spacing.md))
                }
            }
        }
        .onChange(of: search) { _, newValue in
            if newValue.isEmpty {
                isSearching = false
                searchResults = []
            } else {
                performSearch()
            }
        }
        // ScanView sheet removido - não é mais necessário
    }
    
    private func performSearch() {
        guard !search.isEmpty else {
            isSearching = false
            searchResults = []
            return
        }
        
        isSearching = true
        let searchTerm = search.lowercased()
        
        searchResults = hospitalData.plantsInTreatment.filter { plant in
            plant.name.lowercased().contains(searchTerm) ||
            plant.disease.lowercased().contains(searchTerm) ||
            plant.treatment.lowercased().contains(searchTerm)
        }
    }
}

// Card para mostrar resultado da busca
struct PlantSearchResultCard: View {
    let plant: PlantInTreatment
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DS.Spacing.md) {
                // Foto da planta
                if let photo = plant.latestPhoto {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.secondary)
                        )
                }
                
                // Informações da planta
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(plant.name)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(DS.ColorSet.textPrimary)
                        .lineLimit(1)
                    
                    Text(plant.disease)
                        .font(.subheadline)
                        .foregroundColor(DS.ColorSet.textSecondary)
                        .lineLimit(1)
                    
                    HStack {
                        Text(plant.status.rawValue)
                            .font(.caption.weight(.medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(plant.status.color))
                            .cornerRadius(12)
                        
                        Spacer()
                        
                        Text(plant.diagnosisDate.formatted(.dateTime.day().month(.abbreviated)))
                            .font(.caption)
                            .foregroundColor(DS.ColorSet.textSecondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(DS.Spacing.md)
            .background(Color.white)
            .cornerRadius(DS.Radius.lg)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

