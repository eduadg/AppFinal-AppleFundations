import SwiftUI

public struct HomeView: View {
    @State private var search = ""
    @State private var showingScanView = false

    private let tipsData: [TipItem] = [
        .init(title: "Evite molhar folhas à noite", description: "A umidade noturna favorece o desenvolvimento de fungos", icon: "moon.stars.fill"),
        .init(title: "Podar partes doentes", description: "Remova folhas e galhos infectados para evitar propagação", icon: "scissors"),
        .init(title: "Rotacione culturas", description: "Alterne os tipos de plantas para manter o solo saudável", icon: "arrow.triangle.2.circlepath")
    ]



    public init() {}

    public var body: some View {
        ZStack {
            // Fundo principal com gradiente
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.98, blue: 0.96), // Verde muito claro
                    Color(red: 0.85, green: 0.95, blue: 0.90), // Verde claro
                    Color(red: 0.75, green: 0.90, blue: 0.85)  // Verde médio claro
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Padrão sutil de pontos para textura
            GeometryReader { geometry in
                ForEach(0..<20, id: \.self) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: CGFloat.random(in: 2...6))
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
                .padding(.horizontal, DS.Spacing.md)
                .padding(.top, DS.Spacing.sm)
                .padding(.bottom, DS.Spacing.xs)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: DS.Spacing.lg) {

                        SearchBar(text: $search, placeholder: "Buscar planta ou doença…")
                            .padding(.top, DS.Spacing.md)

                        // Layout dos 3 cards principais
                        VStack(spacing: DS.Spacing.md) {
                            // Card A - Diagnosticar agora (largura total)
                            Button(action: {
                                showingScanView = true
                            }) {
                                FeatureCard(
                                    title: "Diagnosticar",
                                    systemImage: "camera.viewfinder",
                                    gradient: LinearGradient(
                                        colors: [
                                            Color(red: 0.22, green: 0.36, blue: 0.29),
                                            Color(red: 0.10, green: 0.33, blue: 0.26)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    roundedCorners: [.allCorners],
                                    bgImageName: "Doenças"
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(height: 160)
                            
                            // Cards B e C lado a lado
                            HStack(spacing: DS.Spacing.md) {
                                // Card B - Hospital
                                Button(action: {
                                    // TODO: Navegar para Hospital
                                }) {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            Image(systemName: "cross.case.fill")
                                                .font(.system(size: 24, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                        .padding(.top, DS.Spacing.md)
                                        .padding(.trailing, DS.Spacing.md)
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Hospital")
                                                .font(.headline.weight(.bold))
                                                .foregroundColor(.white)
                                            Text("0 em tratamento")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, DS.Spacing.md)
                                        .padding(.bottom, DS.Spacing.md)
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
                                                        Color(red: 0.43, green: 0.61, blue: 0.53),
                                                        Color(red: 0.13, green: 0.41, blue: 0.32)
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
                                    // TODO: Navegar para Enciclopédia
                                }) {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            Image(systemName: "book.pages.fill")
                                                .font(.system(size: 24, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                        .padding(.top, DS.Spacing.md)
                                        .padding(.trailing, DS.Spacing.md)
                                        
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
                                        .padding(.horizontal, DS.Spacing.md)
                                        .padding(.bottom, DS.Spacing.md)
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
                                                        Color(red: 0.72, green: 0.84, blue: 0.78),
                                                        Color(red: 0.30, green: 0.53, blue: 0.44)
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
                            .padding(.horizontal, DS.Spacing.xl)
                            .padding(.top, DS.Spacing.sm)

                        TipsCarousel(items: tipsData)
                            .padding(.bottom, DS.Spacing.md)
                    }
                    .padding(.horizontal, DS.Spacing.md)
                    .padding(.bottom, DS.Spacing.lg)
                }
            }
        }
        .sheet(isPresented: $showingScanView) {
            ScanView()
        }
    }
}

