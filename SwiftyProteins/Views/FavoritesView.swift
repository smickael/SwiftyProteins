//
//  FavoritesView.swift
//  SwiftyProteins
//
//  Created by Mickaël on 14/08/2025.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var proteins: Proteins
    
    var body: some View {
        NavigationView {
            List {
                ForEach(proteins.favorites, id: \.id) { protein in
                    NavigationLink(destination: ProteinView(protein: protein)) {
                        Text(protein.name)
                    }
                }
            }
            .navigationBarTitle("Favorites", displayMode: .large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
