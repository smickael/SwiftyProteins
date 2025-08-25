//
//  Loader.swift
//  SwiftyProteins
//
//  Created by Mickaël on 14/08/2025.
//

import SwiftUI

struct Loader: View {
    @Binding var isShowing: Bool
    var text: String = "Loading..."
    
    var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.8)
                    Text(text)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(radius: 10)
                )
            }
            .transition(.opacity)
            .animation(.easeInOut, value: isShowing)
        }
    }
}

#Preview {
    Loader(isShowing: .constant(true), text: "Loading...")
}
