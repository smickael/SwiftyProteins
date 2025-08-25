//
//  ChemicalFormulaView.swift
//  SwiftyProteins
//
//  Created by Mickaël on 16/08/2025.
//

import SwiftUI

struct ChemicalFormulaView: View {
    let formula: String
    
    var body: some View {
        Text("Chemical formula: \(formula)")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.top, 8)
            .fontDesign(.monospaced)
    }
}

#Preview {
    ChemicalFormulaView(formula: "C6H12O6")
}
