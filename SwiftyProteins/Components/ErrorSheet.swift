//
//  ErrorSheet.swift
//  SwiftyProteins
//
//  Created by Mickaël on 14/08/2025.
//

import SwiftUI

struct ErrorSheet: View {
    let errorMessage: String
    @Binding var isPresented: Bool
    let onClose: () -> Void // Callback to handle closing action
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        
                        VStack(alignment: .leading) {
                            Text("Protein Error")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("The protein structure couldn't be loaded")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    Divider()
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Error Details")
                            .font(.headline)
                            .padding(.horizontal)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(errorMessage)
                                .font(.system(.caption, design: .monospaced))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal)
                        VStack(alignment: .leading, spacing: 8) {
                            Label("What does this mean?", systemImage: "info.circle")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                            
                            Text("The SDF file format requires a specific structure. The V2000 line contains the count of atoms and bonds in the molecule. If this line is malformed or missing, the protein cannot be displayed.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Possible solutions", systemImage: "lightbulb")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Try another protein from the list")
                                Text("• Check your internet connection")
                                Text("• The protein file might be corrupted on the server")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                    Spacer()
                }
            }
            .navigationBarTitle("Error Details", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Close") {
                    isPresented = false
                    onClose()
                }
            )
        }
    }
}

struct ErrorDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorSheet(
            errorMessage: """
❌ Compteurs invalides dans le fichier SDF

📋 Format attendu :
[nb_atomes] [nb_liaisons]  0  0  0  0  0999 V2000
Exemple : 12    11  0  0  0  0  0  0  0999 V2000

🔍 Ligne trouvée :
126133  0  0  0  0  0  0  0  0999 V2000
""",
            isPresented: .constant(true),
            onClose: {}
        )
    }
}

