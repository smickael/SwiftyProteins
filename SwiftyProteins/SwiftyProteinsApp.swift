//
//  SwiftyProteinsApp.swift
//  SwiftyProteins
//
//  Created by Mickaël on 14/08/2025.
//

import SwiftUI

@main
struct SwiftyProteinsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var proteins = Proteins(file: "ressources")
    
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(proteins)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    proteins.isUnlocked = false
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    proteins.isUnlocked = false
                }
        }
    }
}
