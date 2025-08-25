//
//  InfosSheet.swift
//  SwiftyProteins
//
//  Created by Mickaël on 14/08/2025.
//

import SwiftUI

struct InfosSheet: View {
    @Binding var atomSelected: String
    @Binding var isPresented: Bool
    @State private var elementInfo: Element?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "atom")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("Atom Information")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Selected: \(atomSelected)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    if isLoading {
                        VStack(spacing: 12) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Text("Fetching element data...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 100)
                    } else if let error = errorMessage {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Error", systemImage: "exclamationmark.triangle")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding()
                                .background(Color(.systemRed).opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    } else if let element = elementInfo {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(element.symbol)
                                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white)
                                        .frame(width: 80, height: 80)
                                        .shadow(radius: 4)
                                        .background(
                                            Circle()
                                                .fill(getElementColor(symbol: element.symbol))
                                                .shadow(radius: 4)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(element.element)
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                        
                                        Text("Atomic Number: \(element.atomicNumber)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                VStack(alignment: .leading, spacing: 8) {
                                    DetailRow(label: "Symbol", value: element.symbol)
                                    DetailRow(label: "Atomic Mass", value: "\(element.atomicMass) u")
                                    DetailRow(label: "Atomic Number", value: "\(element.atomicNumber)")
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Chemical Properties", systemImage: "flask")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("• This atom is part of the molecular structure")
                                    Text("• Chemical bonds connect it to neighboring atoms")
                                    Text("• Element symbol: \(element.symbol)")
                                    Text("• Atomic mass: \(element.atomicMass) atomic mass units")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Data Source", systemImage: "info.circle")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                                
                                Text("Element data retrieved from the Periodic Table of Elements database.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "questionmark.circle")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            
                            Text("No element data available")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 100)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitle("Atom Details", displayMode: .inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    isPresented = false
                }
            )
        }
        .task {
            await loadElementInfo()
        }
        .onChange(of: atomSelected) { _, _ in
            Task {
                await loadElementInfo()
            }
        }
    }
    
    private func loadElementInfo() async {
        isLoading = true
        errorMessage = nil
        elementInfo = nil
        
        do {
            let symbol = extractElementSymbol(from: atomSelected)
            let info = try await fetchElementInfos(symbol: symbol)
            
            await MainActor.run {
                self.elementInfo = info
                self.isLoading = false
                if info == nil {
                    self.errorMessage = "Element '\(symbol)' not found in database"
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to fetch element data: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    private func extractElementSymbol(from atomName: String) -> String {
        let letters = atomName.filter { $0.isLetter }
        return String(letters.prefix(2))
    }
    
    private func getElementColor(symbol: String) -> Color {
        let key = symbol.uppercased()
        if let uiColor = CPKColor[key] {
            return Color(uiColor)
        }
        return Color.purple
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}

struct InfosSheet_Previews: PreviewProvider {
    static var previews: some View {
        InfosSheet(atomSelected: .constant("C1"), isPresented: .constant(true))
    }
}
