import SwiftUI

public struct HospitalView: View {
    @StateObject private var hospitalData = HospitalDataManager.shared
    @State private var showingAddPlant = false
    
    public init() {}
    
    public var body: some View {
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
                
                VStack(spacing: 0) {
                    if hospitalData.plantsInTreatment.isEmpty {
                        // Empty State
                        VStack(spacing: DS.Spacing.lg) {
                            Spacer()
                            
                            Image(systemName: "cross.case")
                                .font(.system(size: 64))
                                .foregroundColor(DS.ColorSet.textSecondary)
                            
                            VStack(spacing: DS.Spacing.sm) {
                                Text("Nenhuma planta em tratamento")
                                    .font(.title2.weight(.semibold))
                                    .foregroundColor(DS.ColorSet.textPrimary)
                                
                                Text("Quando você diagnosticar uma planta doente, ela aparecerá aqui para acompanhamento")
                                    .font(.body)
                                    .foregroundColor(DS.ColorSet.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, DS.Spacing.xl)
                            }
                            
                            Spacer()
                        }
                    } else {
                        // Plants List
                        ScrollView {
                            LazyVStack(spacing: DS.Spacing.md) {
                                ForEach(hospitalData.plantsInTreatment) { plant in
                                    NavigationLink(destination: PlantDetailView(plant: plant)) {
                                        PlantCard(plant: plant)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, DS.Spacing.md)
                            .padding(.vertical, DS.Spacing.sm)
                        }
                    }
                }
            }
            .navigationTitle("Minhas Plantas em Tratamento")
            .navigationBarTitleDisplayMode(.large)
            .overlay(
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingAddPlant = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(DS.ColorSet.brand)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, DS.Spacing.lg)
                        .padding(.bottom, DS.Spacing.lg)
                    }
                }
            )
        }
        .sheet(isPresented: $showingAddPlant) {
            AddPlantManuallyView()
        }
    }
}

struct PlantCard: View {
    let plant: PlantInTreatment
    
    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            // Plant Photo
            Group {
                if let photo = plant.latestPhoto {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "photo")
                        .font(.system(size: 24))
                        .foregroundColor(DS.ColorSet.textSecondary)
                }
            }
            .frame(width: 60, height: 60)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .clipped()
            
            // Plant Info
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                HStack {
                    Text(plant.name)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(DS.ColorSet.textPrimary)
                    
                    Spacer()
                    
                    // Status Badge
                    HStack(spacing: 4) {
                        Image(systemName: plant.status.iconName)
                            .font(.system(size: 12, weight: .medium))
                        
                        Text(plant.status.rawValue)
                            .font(.caption.weight(.medium))
                    }
                    .foregroundColor(Color(plant.status.color))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(plant.status.color).opacity(0.1))
                    .cornerRadius(12)
                }
                
                Text(plant.disease)
                    .font(.subheadline)
                    .foregroundColor(DS.ColorSet.textSecondary)
                
                Text("Última atualização: \(plant.lastUpdate.formatted(.dateTime.day().month(.abbreviated)))")
                    .font(.caption)
                    .foregroundColor(DS.ColorSet.textSecondary)
            }
            
            Spacer()
        }
        .padding(DS.Spacing.md)
        .background(Color.white)
        .cornerRadius(DS.Radius.lg)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

// Placeholder for Add Plant Manually View
struct AddPlantManuallyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Adicionar Planta Manualmente")
                    .font(.title2)
                    .padding()
                
                Text("Funcionalidade em desenvolvimento")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Nova Análise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    HospitalView()
}
