import SwiftUI
import AVFoundation

public struct ScanView: View {
    @State private var isCameraAuthorized = false
    @State private var showingImagePicker = false
    @State private var capturedImage: UIImage?
    @State private var showingResults = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Fundo da câmera ou placeholder
            if isCameraAuthorized {
                CameraPreviewView()
                    .ignoresSafeArea()
            } else {
                // Placeholder quando não há permissão
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.25, blue: 0.20),
                        Color(red: 0.10, green: 0.20, blue: 0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    Image(systemName: "camera.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.3))
                    Text("Camera access needed")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top)
                    Spacer()
                }
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
                            Text("Scan Your Plant")
                                .font(.title2.weight(.semibold))
                                .foregroundColor(DS.ColorSet.textPrimary)
                            
                            Text("Position your plant within the frame and tap capture")
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
                                            .fill(Color(red: 0.20, green: 0.42, blue: 0.35))
                                            .frame(width: 60, height: 60)
                                    )
                                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                            }
                            
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
        .onAppear {
            requestCameraPermission()
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.isCameraAuthorized = granted
            }
        }
    }
    
    private func capturePhoto() {
        // Simular captura da foto
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Aqui você integraria com a câmera real
            capturedImage = UIImage(systemName: "leaf.fill") // Placeholder
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

// Preview da câmera (placeholder - integraria com AVFoundation)
struct CameraPreviewView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray
        
        // Aqui você integraria com AVCaptureVideoPreviewLayer
        // Por enquanto, vamos usar uma cor de placeholder
        view.backgroundColor = UIColor(red: 0.2, green: 0.3, blue: 0.25, alpha: 1.0)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Atualizar view se necessário
    }
}
