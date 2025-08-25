//
//  Element.swift
//  SwiftyProteins
//
//  Created by Mickaël on 14/08/2025.
//

import SwiftUI

struct Element: Identifiable {
    let id = UUID()
    let atomicNumber: Int
    let element: String
    let symbol: String
    let atomicMass: String
}

@MainActor
func fetchElementInfos(symbol: String) async throws -> Element? {
    guard let url = URL(string: "https://gist.githubusercontent.com/GoodmanSciences/c2dd862cd38f21b0ad36b8f96b4bf1ee/raw/1d92663004489a5b6926e944c1b3d9ec5c40900e/Periodic%2520Table%2520of%2520Elements.csv") else {
        return nil
    }
    
    let (data, _) = try await URLSession.shared.data(from: url)
    
    guard let csvString = String(data: data, encoding: .utf8) else {
        return nil
    }
    
    let rows = csvString.components(separatedBy: "\n").dropFirst()
    for row in rows {
        let columns = row.components(separatedBy: ",")
        if columns.count > 3 {
            let currentSymbol = columns[2].trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            if currentSymbol == symbol.uppercased() {
                let atomicNumber = Int(columns[0]) ?? 0
                let elementName = columns[1]
                let atomicMass = columns[3]
                return Element(
                    atomicNumber: atomicNumber,
                    element: elementName,
                    symbol: currentSymbol,
                    atomicMass: atomicMass
                )
            }
        }
    }
    return nil
}
