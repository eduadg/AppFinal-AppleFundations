import SwiftUI

struct CustomDiseaseView: View {
    @Binding var customDisease: String
    @Binding var customTreatment: String
    @Environment(\.dismiss) private var dismiss
    
    private var isFormValid: Bool {
        !customDisease.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !customTreatment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
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
                    VStack(spacing: DS.Spacing.lg) {
                        // Disease Name Section
                        VStack(spacing: DS.Spacing.md) {
                            Text("Nome da Doença/Condição")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(DS.ColorSet.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            TextField("Ex: Mancha bacteriana, Oídio...", text: $customDisease)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.body)
                        }
                        .padding(DS.Spacing.md)
                        .background(Color.white)
                        .cornerRadius(DS.Radius.lg)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                        
                        // Treatment Section
                        VStack(spacing: DS.Spacing.md) {
                            Text("Tratamento Recomendado")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(DS.ColorSet.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            TextField("Descreva o tratamento recomendado...", text: $customTreatment)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.body)
                                .lineLimit(4...8)
                        }
                        .padding(DS.Spacing.md)
                        .background(Color.white)
                        .cornerRadius(DS.Radius.lg)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                        
                        // Tips Section
                        VStack(spacing: DS.Spacing.md) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(DS.ColorSet.brand)
                                
                                Text("Dicas para um bom tratamento")
                                    .font(.headline.weight(.semibold))
                                    .foregroundColor(DS.ColorSet.textPrimary)
                            }
                            
                            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                                CustomTipItem(text: "Seja específico sobre os produtos a serem usados")
                                CustomTipItem(text: "Inclua a frequência de aplicação")
                                CustomTipItem(text: "Mencione cuidados ambientais (luz, água, etc.)")
                                CustomTipItem(text: "Adicione medidas preventivas")
                            }
                        }
                        .padding(DS.Spacing.md)
                        .background(DS.ColorSet.brandMuted.opacity(0.3))
                        .cornerRadius(DS.Radius.lg)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, DS.Spacing.md)
                    .padding(.top, DS.Spacing.md)
                }
            }
            .navigationTitle("Doença Personalizada")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(DS.ColorSet.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Confirmar") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid)
                }
            }
        }
    }
}

struct CustomTipItem: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: DS.Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DS.ColorSet.brand)
                .padding(.top, 2)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(DS.ColorSet.textSecondary)
        }
    }
}
