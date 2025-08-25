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
    @State private var showButtonFaceID = true
    @State private var showAlert = false
    @State private var textAlert = ""
    
    var body: some View {
        Group {
            if proteins.isUnlocked {
                BottomNavigation()
            } else {
                ZStack {
                    Image("SplashScreen")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .scaleEffect(1.08)
                        .offset(x: -30)
                        .clipped()
                        .ignoresSafeArea()
                        .accessibilityHidden(true)
                        .blur(radius: 3)
                    VStack(alignment: .center, spacing: 42) {
                        VStack(spacing: 16) {
                            Image("Image")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 96, height: 96)
                                .accessibilityHidden(true)
                                .cornerRadius(20)
                            Text("Swifty\nProteins")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                        }
                        if showButtonFaceID {
                            Button(action: { self.authenticate() }) {
                                ZStack {
                                    Circle().foregroundColor(Color("Button")).shadow(radius: 30)
                                    Image(systemName: "faceid")
                                        .font(.system(size: 42))
                                        .foregroundColor(Color("Shadow"))
                                }
                                .frame(width: 100, height: 100)
                            }
                            .alert(isPresented: $showAlert) {
                                Alert(title: Text("Face ID Error"), message: Text(textAlert), dismissButton: .cancel())
                            }
                        } else {
                            Button(action: { self.proteins.isUnlocked.toggle() }) {
                                Text("Unlock without Face ID or Touch ID")
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: proteins.isUnlocked)
        .onAppear(perform: checkFaceID)
    }
    
    /* Functions */
    
    func    checkFaceID() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:
                self.showButtonFaceID = true
            case .touchID:
                self.showButtonFaceID = true
            case .none:
                self.showButtonFaceID = false
            default:
                self.showButtonFaceID = false
            }
        }
    }
    
    func    authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate yourself with FaceID."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authentificationError in
                DispatchQueue.main.async {
                    if success {
                        self.proteins.isUnlocked.toggle()
                    } else {
                        self.textAlert = "Please authenticate yourself with FaceID."
                        self.showAlert = true
                    }
                }
            }
        } else {
            self.textAlert = "FaceID has not been activated."
            self.showAlert = true
        }
    }
    /* End Functions */
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(Proteins(file: "ressources"))
            .environment(\.colorScheme, .light)
    }
}


#Preview {
    LoginView()
}
