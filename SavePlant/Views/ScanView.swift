import SwiftUI

public struct ScanView: View {
    @State private var capturedImage: UIImage?
    @State private var showingResults = false
    @State private var isScanning = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Fundo simulado da câmera
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.25, blue: 0.20),
                    Color(red: 0.10, green: 0.20, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Adicionar algumas "folhas" simuladas para parecer uma câmera real
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green.opacity(0.3))
                        .offset(x: -50, y: -30)
                    
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green.opacity(0.2))
                        .offset(x: 20, y: 50)
                    Spacer()
                }
                Spacer()
            }
            
            // Overlay com interface de scan
            VStack {
                // Status bar area
                Color.clear
                    .frame(height: 50)
                
                Spacer()
                
                // Área de foco central (quadrado com cantos)
                ZStack {
                    // Overlay escuro com buraco transparente no meio
                    Rectangle()
                        .fill(Color.black.opacity(0.4))
                        .mask(
                            Rectangle()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .frame(width: 250, height: 250)
                                        .blendMode(.destinationOut)
                                )
                        )
                    
                    // Moldura de foco com cantos
                    ScanFrameView()
                        .frame(width: 250, height: 250)
                }
                
                Spacer()
                
                // Bottom sheet com controles
                VStack(spacing: 20) {
                    // Indicador de arrastar
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 40, height: 5)
                        .padding(.top, 10)
                    
                    if showingResults {
                        // Resultado após captura
                        VStack(spacing: 16) {
                            Text("Plant Analysis")
                                .font(.title2.weight(.semibold))
                                .foregroundColor(DS.ColorSet.textPrimary)
                            
                            Text("Analyzing your plant...")
                                .font(.body)
                                .foregroundColor(DS.ColorSet.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            // Botão Next
                            Button(action: {
                                // Ação do Next
                                showingResults = false
                            }) {
                                HStack {
                                    Text("Next")
                                        .font(.headline.weight(.semibold))
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(red: 0.20, green: 0.42, blue: 0.35))
                                .cornerRadius(25)
                            }
                            .padding(.horizontal, 20)
                        }
                    } else {
                        // Interface inicial
                        VStack(spacing: 16) {
                            Text(isScanning ? "Scanning..." : "Scan Your Plant")
                                .font(.title2.weight(.semibold))
                                .foregroundColor(DS.ColorSet.textPrimary)
                            
                            Text(isScanning ? "Analyzing your plant..." : "Position your plant within the frame and tap capture")
                                .font(.body)
                                .foregroundColor(DS.ColorSet.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            // Botão de captura
                            Button(action: {
                                capturePhoto()
                            }) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 70, height: 70)
                                    .overlay(
                                        Circle()
                                            .fill(isScanning ? Color.gray : Color(red: 0.20, green: 0.42, blue: 0.35))
                                            .frame(width: 60, height: 60)
                                            .scaleEffect(isScanning ? 0.8 : 1.0)
                                            .animation(.easeInOut(duration: 0.2), value: isScanning)
                                    )
                                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                            }
                            .disabled(isScanning)
                            
                            // Botão Capture Again (se já capturou)
                            if capturedImage != nil {
                                Button("Capture Again") {
                                    capturedImage = nil
                                    showingResults = false
                                }
                                .font(.body)
                                .foregroundColor(DS.ColorSet.textSecondary)
                                .padding(.top, 8)
                            }
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .frame(maxWidth: .infinity)
                .background(
                    Color.white
                        .cornerRadius(25, corners: [.topLeft, .topRight])
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                )
                .padding(.horizontal, 0)
            }
        }
    }
    
    private func capturePhoto() {
        // Simular captura da foto com animação
        isScanning = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Simular análise
            capturedImage = UIImage(systemName: "leaf.fill") // Placeholder
            isScanning = false
            showingResults = true
        }
    }
}

// Componente para a moldura de foco
struct ScanFrameView: View {
    var body: some View {
        ZStack {
            // Cantos da moldura
            ForEach(0..<4) { index in
                CornerFrame()
                    .rotationEffect(.degrees(Double(index * 90)))
            }
        }
    }
}

struct CornerFrame: View {
    var body: some View {
        VStack {
            HStack {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 30, height: 4)
                    .cornerRadius(2)
                Spacer()
            }
            HStack {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 4, height: 30)
                    .cornerRadius(2)
                Spacer()
            }
            Spacer()
        }
        .frame(width: 125, height: 125)
    }
}


