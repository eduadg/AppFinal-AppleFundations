import SwiftUI

struct DiseasePickerView: View {
    @Binding var selectedDisease: CommonDisease?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.99, blue: 0.98),
                        Color(red: 0.94, green: 0.97, blue: 0.95),
                        Color(red: 0.92, green: 0.95, blue: 0.93)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: DS.Spacing.md) {
                        ForEach(CommonDisease.commonDiseases) { disease in
                            DiseaseCard(
                                disease: disease,
                                isSelected: selectedDisease?.id == disease.id
                            ) {
                                selectedDisease = disease
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal, DS.Spacing.md)
                    .padding(.vertical, DS.Spacing.sm)
                }
            }
            .navigationTitle("Doenças Comuns")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(DS.ColorSet.textSecondary)
                }
            }
        }
    }
}

struct DiseaseCard: View {
    let disease: CommonDisease
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DS.Spacing.md) {
                // Icon
                Image(systemName: disease.iconName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(isSelected ? .white : DS.ColorSet.brand)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(isSelected ? DS.ColorSet.brand : DS.ColorSet.brandMuted)
                    )
                
                // Content
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(disease.name)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(isSelected ? .white : DS.ColorSet.textPrimary)
                    
                    Text(disease.description)
                        .font(.subheadline)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : DS.ColorSet.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(DS.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.lg)
                    .fill(isSelected ? DS.ColorSet.brand : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.lg)
                    .stroke(isSelected ? DS.ColorSet.brand : Color.clear, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
