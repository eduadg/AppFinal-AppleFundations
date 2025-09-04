import SwiftUI

public struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    
    public init(text: Binding<String>, placeholder: String = "Search") {
        self._text = text
        self.placeholder = placeholder
    }
    
    public var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
        }
        .padding(.vertical, DS.Spacing.sm)
        .padding(.horizontal, DS.Spacing.md)
        // Fundo branco + sombra mais marcada, igual ao mock
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .strokeBorder(Color(.systemGray3).opacity(0.25), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)
        .accessibilityLabel(Text("Search bar"))
    }
}
