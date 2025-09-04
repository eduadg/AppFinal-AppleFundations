import SwiftUI

public struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    var onSearch: (() -> Void)?
    @FocusState private var isFocused: Bool
    
    public init(text: Binding<String>, placeholder: String = "Search", onSearch: (() -> Void)? = nil) {
        self._text = text
        self.placeholder = placeholder
        self.onSearch = onSearch
    }
    
    public var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .focused($isFocused)
                .onSubmit {
                    onSearch?()
                }
                .onTapGesture {
                    isFocused = true
                }
                .submitLabel(.search)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    isFocused = true
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, DS.Spacing.sm)
        .padding(.horizontal, DS.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .strokeBorder(isFocused ? DS.ColorSet.brand : Color(.systemGray3).opacity(0.25), lineWidth: isFocused ? 2 : 0.5)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)
        .onTapGesture {
            isFocused = true
        }
        .contentShape(Rectangle()) // Garante que toda a área seja clicável
    }
}
