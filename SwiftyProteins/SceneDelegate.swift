//
//  SceneDelegate.swift
//  SwiftyProteins
//
//  Created by Mickaël on 14/08/2025.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let proteins = Proteins(file: "ressources")

    // Configure et attache la fenêtre à la scène fournie
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let contentView = LoginView().environmentObject(proteins)

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    // Libère les ressources lors de la déconnexion de la scène
    func sceneDidDisconnect(_ scene: UIScene) {
        proteins.isUnlocked = false
    }

    // Redémarre les tâches lorsque la scène devient active
    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    // Gère le passage de la scène à l'état inactif
    func sceneWillResignActive(_ scene: UIScene) {
        proteins.isUnlocked = false
    }

    // Transition de l'arrière-plan vers le premier plan
    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    // Transition du premier plan vers l'arrière-plan
    func sceneDidEnterBackground(_ scene: UIScene) {
        proteins.isUnlocked = false
    }
}
