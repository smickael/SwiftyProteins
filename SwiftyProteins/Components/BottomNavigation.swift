//
//  BottomNavigation.swift
//  SwiftyProteins
//
//  Created by Mickaël on 14/08/2025.
//

import SwiftUI

struct BottomNavigation: View {
    var body: some View {
        TabView {
            ProteinsListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Proteins")
                }
            FavoritesView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Favorites")
                }
        }
    }
}
