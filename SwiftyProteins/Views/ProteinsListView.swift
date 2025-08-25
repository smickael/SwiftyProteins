//
//  ProteinsListView.swift
//  SwiftyProteins
//
//  Created by Mickaël on 14/08/2025.
//

import SwiftUI

struct ProteinsListView: View {
    @EnvironmentObject var proteins: Proteins
    @State private var searchValue: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading, spacing: 16) {
                    Search(text: $searchValue)
                    
                    List {
                        ForEach(proteins.proteins.filter {
                            searchValue.isEmpty ? true : $0.name.contains(searchValue.uppercased())
                        }, id: \.id) { protein in
                            NavigationLink(destination: ProteinView(protein: protein)) {
                                Text(protein.name)
                                    .foregroundColor(.primary)
                            }
                        }
                        .listRowBackground(Color("Background"))
                    }
                    .onAppear {
                        UITableView.appearance().backgroundColor = UIColor(named: "Background")
                        UITableView.appearance().separatorColor = UIColor(named: "Shadow")
                        UITableView.appearance().separatorStyle = .singleLine
                    }
                    .id(UUID())
                }
                .navigationBarTitle("Proteins", displayMode: .large)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ProteinsListView_Previews: PreviewProvider {
    static var previews: some View {
        ProteinsListView()
            .environmentObject(Proteins(file: "ressources"))
            .environment(\.colorScheme, .light)
    }
}
