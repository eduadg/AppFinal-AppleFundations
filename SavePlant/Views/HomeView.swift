import SwiftUI

public struct HomeView: View {
    @State private var search = ""

    private let qaMock: [QAItem] = [
        .init(title: "What is the role of Polypodiophyta as host plant for bacterial plant pathogens?", answers: 8,  avatars: ["leaf.fill","tortoise.fill","ladybug.fill","camera.fill"]),
        .init(title: "What could treat and remediate cumin/Nigella sativa?", answers: 5, avatars: ["flame.fill","drop.fill","hare.fill","face.smiling"]),
        .init(title: "How to identify nutrient deficiency by leaf patterns?", answers: 12, avatars: ["bolt.fill","sun.max.fill","cloud.fill","leaf.fill"])
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
                    Text("SavePlant")
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

                        SearchBar(text: $search)
                            .padding(.top, DS.Spacing.md)

                        // Layout seguindo EXATAMENTE a inspiração
                        VStack(spacing: DS.Spacing.md) {
                            // Primeira linha: card pequeno + card grande vertical (como na inspiração)
                            HStack(alignment: .top, spacing: DS.Spacing.md) {
                                // Card "Doenças" - pequeno quadrado (como o primeiro da inspiração)
                                FeatureCard(
                                    title: "Doenças",
                                    systemImage: "cross.circle.fill",
                                    gradient: LinearGradient(
                                        colors: [
                                            Color(red: 0.22, green: 0.36, blue: 0.29),
                                            Color(red: 0.10, green: 0.33, blue: 0.26)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    roundedCorners: [.topLeft, .bottomRight],
                                    bgImageName: "Doenças"
                                )
                                .frame(width: 155, height: 155)
                                
                                // Card "Inspirations" - grande vertical (como o da direita na inspiração)
                                FeatureCard(
                                    title: "Inspirations",
                                    systemImage: "sparkles",
                                    gradient: LinearGradient(
                                        colors: [
                                            Color(red: 0.43, green: 0.61, blue: 0.53),
                                            Color(red: 0.13, green: 0.41, blue: 0.32)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    roundedCorners: [.topRight, .bottomRight]
                                )
                                .frame(width: 155, height: 200)
                            }
                            
                            // Segunda linha: card médio + botão (como na inspiração)
                            HStack(spacing: DS.Spacing.md) {
                                // Card "Find A Plant" - médio horizontal (como o inferior esquerdo)
                                FeatureCard(
                                    title: "Find A Plant",
                                    systemImage: "magnifyingglass",
                                    gradient: LinearGradient(
                                        colors: [
                                            Color(red: 0.72, green: 0.84, blue: 0.78),
                                            Color(red: 0.30, green: 0.53, blue: 0.44)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    roundedCorners: [.topLeft, .bottomLeft]
                                )
                                .frame(width: 155, height: 120)
                                
                                // Botão DONATE - mesmo tamanho do card ao lado
                                Button("DONATE") { }
                                    .buttonStyle(PrimaryButtonStyle(height: 60))
                                    .frame(width: 155, height: 120)
                            }
                        }

                        Text("Community Questions")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(DS.ColorSet.textPrimary)
                            .padding(.horizontal, DS.Spacing.xl)
                            .padding(.top, DS.Spacing.sm)

                        QACarousel(items: qaMock)
                            .padding(.bottom, DS.Spacing.md)
                    }
                    .padding(.horizontal, DS.Spacing.md)
                }
            }
        }
    }
}

