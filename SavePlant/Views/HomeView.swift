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

                        SearchBar(text: $search, placeholder: "Buscar planta ou doença…")
                            .padding(EdgeInsets(top: DS.Spacing.md, leading: 0, bottom: 0, trailing: 0))

                        // Layout dos 3 cards principais
                        VStack(spacing: DS.Spacing.md) {
                            // Card A - Diagnosticar agora (largura total)
                            Button(action: {
                                showingScanView = true
                            }) {
                                VStack(alignment: .leading, spacing: DS.Spacing.md) {
                                    Spacer()
                                    
                                    // Ícone e texto na mesma linha
                                    HStack(alignment: .center, spacing: DS.Spacing.md) {
                                        Image(systemName: "camera.viewfinder")
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.white)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Diagnosticar")
                                                .font(.headline.weight(.bold))
                                                .foregroundColor(.white)
                                            Text("Use a câmera para analisar")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(EdgeInsets(top: 0, leading: DS.Spacing.md, bottom: 0, trailing: DS.Spacing.md))
                                    
                                    Spacer()
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
                                    // Navegação para Hospital será feita via TabView
                                    // Por enquanto, mostra uma mensagem informativa
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
                                            Text("0 em tratamento")
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
                                    // Navegação para Enciclopédia será feita via TabView
                                    // Por enquanto, mostra uma mensagem informativa
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
                    .padding(EdgeInsets(top: 0, leading: DS.Spacing.md, bottom: DS.Spacing.lg, trailing: DS.Spacing.md))
                }
            }
        }
        .sheet(isPresented: $showingScanView) {
            ScanView()
        }
    }
}

