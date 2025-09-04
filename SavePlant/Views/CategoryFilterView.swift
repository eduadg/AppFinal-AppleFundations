import SwiftUI

public struct CategoryFilterView: View {
    @Binding var selectedCategory: PostCategory?
    let onCategorySelected: (PostCategory?) -> Void
    
    public init(selectedCategory: Binding<PostCategory?>, onCategorySelected: @escaping (PostCategory?) -> Void) {
        self._selectedCategory = selectedCategory
        self.onCategorySelected = onCategorySelected
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.sm) {
                // All Categories Button
                Button(action: {
                    selectedCategory = nil
                    onCategorySelected(nil)
                }) {
                    HStack(spacing: DS.Spacing.xs) {
                        Image(systemName: "list.bullet")
                            .font(.caption)
                        Text("Todas")
                            .font(.caption.weight(.medium))
                    }
                    .foregroundColor(selectedCategory == nil ? .white : DS.ColorSet.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(selectedCategory == nil ? DS.ColorSet.brand : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(selectedCategory == nil ? DS.ColorSet.brand : DS.ColorSet.textSecondary.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(20)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Category Buttons
                ForEach(PostCategory.allCases, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                        onCategorySelected(category)
                    }) {
                        HStack(spacing: DS.Spacing.xs) {
                            Image(systemName: category.icon)
                                .font(.caption)
                            Text(category.rawValue)
                                .font(.caption.weight(.medium))
                        }
                        .foregroundColor(selectedCategory == category ? .white : category.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedCategory == category ? category.color : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(selectedCategory == category ? category.color : category.color.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(20)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, DS.Spacing.md)
        }
    }
}

// MARK: - Preview
struct CategoryFilterView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryFilterView(
            selectedCategory: .constant(nil),
            onCategorySelected: { _ in }
        )
        .padding()
        .background(Color(.systemGray6))
    }
}
