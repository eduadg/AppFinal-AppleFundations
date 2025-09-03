import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    let sourceType: UIImagePickerController.SourceType
    
    init(selectedImage: Binding<UIImage?>, sourceType: UIImagePickerController.SourceType = .photoLibrary) {
        self._selectedImage = selectedImage
        self.sourceType = sourceType
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            
            // Notificação com o nome do arquivo (se disponível)
            if let url = info[.imageURL] as? URL {
                NotificationCenter.default.post(name: .imagePickerSelectedFileName,
                                                object: nil,
                                                userInfo: ["filename": url.lastPathComponent])
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct ImagePickerActionSheet: View {
    @Binding var selectedImage: UIImage?
    @Binding var showingImagePicker: Bool
    @State private var showingActionSheet = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        Button(action: {
            showingActionSheet = true
        }) {
            ZStack {
                if let photo = selectedImage {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(DS.Radius.lg)
                } else {
                    RoundedRectangle(cornerRadius: DS.Radius.lg)
                        .fill(Color(.systemGray6))
                        .frame(height: 200)
                        .overlay(
                            VStack(spacing: DS.Spacing.sm) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(DS.ColorSet.textSecondary)
                                
                                Text("Tirar ou selecionar foto")
                                    .font(.subheadline)
                                    .foregroundColor(DS.ColorSet.textSecondary)
                            }
                        )
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .confirmationDialog("Selecionar Foto", isPresented: $showingActionSheet) {
            Button("Câmera") {
                DispatchQueue.main.async {
                    sourceType = .camera
                    showingImagePicker = true
                }
            }
            Button("Galeria") {
                DispatchQueue.main.async {
                    sourceType = .photoLibrary
                    showingImagePicker = true
                }
            }
            Button("Cancelar", role: .cancel) { }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
        }
    }
}

// Notificação para compartilhar o nome do arquivo selecionado
extension Notification.Name {
    static let imagePickerSelectedFileName = Notification.Name("imagePickerSelectedFileName")
}
