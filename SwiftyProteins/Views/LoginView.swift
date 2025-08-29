//
//  LoginView.swift
//  SwiftyProteins
//
//  Created by Mickaël on 14/08/2025.
//

import SwiftUI
import LocalAuthentication

struct LoginView: View {
    
    @EnvironmentObject var proteins: Proteins
    
    @State private var showAlert = false
    @State private var textAlert = ""
    
    @State private var username = ""
    @State private var password = ""
    
    @State private var accountExists = false
    @State private var savedUsername = ""
    
    @State private var showSplash = true
    
    var body: some View {
        Group {
            if proteins.isUnlocked {
                BottomNavigation()
            } else {
                ZStack {
                    Image("SplashScreen")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                        .accessibilityHidden(true)
                        .scaleEffect(1.1)
                        .offset(x: -6)
                        .blur(radius: 1)
                    
                    if showSplash {
                        VStack(spacing: 16) {
                            Image("Image")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 96, height: 96)
                                .cornerRadius(20)
                                .accessibilityHidden(true)
                            Text("Swifty\nProteins")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                        }
                    } else {
                        VStack(spacing: 32) {
                            
                            VStack(spacing: 16) {
                                Image("Image")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 96, height: 96)
                                    .cornerRadius(20)
                                    .accessibilityHidden(true)
                                Text("Swifty\nProteins")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.center)
                            }
                            
                            if accountExists {
                                Text("Log in as \(savedUsername)")
                                    .font(.subheadline.bold())
                            } else {
                                Text("Create your account")
                                    .font(.subheadline.bold())
                            }
                            
                            VStack(spacing: 16) {
                                TextField("Username", text: $username)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                SecureField("Password", text: $password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            Button(action: {
                                if accountExists {
                                    login()
                                } else {
                                    createAccount()
                                }
                            }) {
                                Text(accountExists ? "Login" : "Create Account")
                                    .fontWeight(.semibold)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color("Button"))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            
                            if accountExists {
                                Button(action: { authenticate() }) {
                                    HStack {
                                        Image(systemName: "faceid")
                                            .font(.system(size: 24))
                                        Text("Login with Face ID")
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .frame(maxWidth: 400)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .onAppear {
                    loadAccount()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        withAnimation(.easeInOut) {
                            showSplash = false
                        }
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: proteins.isUnlocked)
    }
    
    // MARK: - Functions
    
    func loadAccount() {
        if let savedUser = UserDefaults.standard.string(forKey: "username"),
           let _ = UserDefaults.standard.string(forKey: "password") {
            accountExists = true
            savedUsername = savedUser
            username = savedUser
        } else {
            accountExists = false
        }
    }
    
    func createAccount() {
        guard !username.isEmpty, !password.isEmpty else {
            textAlert = "Please fill all fields."
            showAlert = true
            return
        }
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(password, forKey: "password")
        savedUsername = username
        accountExists = true
        proteins.isUnlocked = true
    }
    
    func login() {
        let storedUser = UserDefaults.standard.string(forKey: "username")
        let storedPass = UserDefaults.standard.string(forKey: "password")
        
        if username == storedUser && password == storedPass {
            proteins.isUnlocked = true
        } else {
            textAlert = "Invalid username or password."
            showAlert = true
        }
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Login with Face ID"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                DispatchQueue.main.async {
                    if success {
                        proteins.isUnlocked = true
                    } else {
                        textAlert = "Face ID failed."
                        showAlert = true
                    }
                }
            }
        } else {
            textAlert = "Face ID not available."
            showAlert = true
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(Proteins(file: "ressources"))
        .environment(\.colorScheme, .light)
}
