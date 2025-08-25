//
//  ProteinView.swift
//  SwiftyProteins
//
//  Created by Mickaël on 14/08/2025.
//

import SwiftUI
import SceneKit
import MetalKit
import CoreMotion

struct ProteinView: View {
    @EnvironmentObject var proteins: Proteins
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var pointer = UnsafeMutablePointer<SCNNode>.allocate(capacity: 1)
    @State var showCardAtom = false
    @State var showAlert = false
    @State var showErrorSheet = false
    @State var alertErrorMessage: String = ""
    @State var showSpinningWheel = true
    @State var atomSelected: String = ""
    @State var isLoading = true
    @State var chemicalFormula: String = "Unavailable formula"
    let scene = SCNScene()
    var protein: Protein
    @State var showHydrogen: Bool = true
    @State var squareHydrogenShape: Bool = false
    @State var scientificMode: Bool = false
    @State private var showOptionsMenu = false
    
    @State private var showFavoriteAlert = false
    @State private var favoriteAlertMessage = ""
    
    // CoreMotion properties for parallax effect
    @State private var motionManager = CMMotionManager()
    @State private var parallaxOffset = CGSize.zero
    
    // Consts for parallax effect
    private let parallaxFactor: CGFloat = 22
    private let parallaxClamp: CGFloat = 50
    private let parallaxSmoothing: CGFloat = 0.12
    private let parallaxJitterThreshold: CGFloat = 0.15
    
    // Const for scientific background scale
    private let scientificBackgroundScale: CGFloat = 1.8
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                ChemicalFormulaView(formula: chemicalFormula)
                ZStack {
                    if scientificMode {
                        GeometryReader { geometry in
                            let scale: CGFloat = scientificBackgroundScale
                            let extraX = (scale - 1) * geometry.size.width / 2
                            let extraY = (scale - 1) * geometry.size.height / 2
                            let clampedX = min(max(parallaxOffset.width, -extraX), extraX)
                            let clampedY = min(max(parallaxOffset.height, -extraY), extraY)
                            Image("ContaminationBackground")
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .scaleEffect(scale, anchor: .center)
                                .offset(x: clampedX, y: clampedY)
                                .opacity(0.8)
                                .blur(radius: 0.5)
                                .allowsHitTesting(false)
                                .clipped()
                                .blur(radius: 2)
                        }
                    }
                    
                    SceneKitView(
                        scene: scene,
                        show: $showCardAtom,
                        atomSelected: $atomSelected,
                        pointer: pointer,
                        protein: protein
                    )
                    .background(scientificMode ? Color.clear : Color(.systemGray6))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                
                HStack(spacing: 12) {
                    // Bouton Options
                    Button(action: {
                        showOptionsMenu = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.blue)
                            
                            Text("Options")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 0.5)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .confirmationDialog("Options", isPresented: $showOptionsMenu, titleVisibility: .visible) {
                        Button("Show Hydrogen: \(showHydrogen ? "ON" : "OFF")") {
                            showHydrogen.toggle()
                            Task {
                                let result = await proteins.createScene(name: protein.name, scene: scene, showHydrogen: showHydrogen, squareHydrogenShape: squareHydrogenShape)
                                if !result.success {
                                    self.alertErrorMessage = result.errorMessage ?? "Unknown error"
                                    showErrorSheet = true
                                }
                            }
                        }
                        
                        Button("Square Hydrogen: \(squareHydrogenShape ? "ON" : "OFF")") {
                            squareHydrogenShape.toggle()
                            Task {
                                let result = await proteins.createScene(name: protein.name, scene: scene, showHydrogen: showHydrogen, squareHydrogenShape: squareHydrogenShape)
                                if !result.success {
                                    self.alertErrorMessage = result.errorMessage ?? "Unknown error"
                                    showErrorSheet = true
                                }
                            }
                        }
                        .disabled(!showHydrogen)
                        
                        Button("Scientific Mode: \(scientificMode ? "ON" : "OFF")") {
                            scientificMode.toggle()
                        }
                        
                        Button("Cancel", role: .cancel) { }
                    }
                    
                    // Favorite button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            let wasFavorite = proteins.isFavorite(protein)
                            proteins.toggleFavorite(protein)
                            favoriteAlertMessage = wasFavorite ? "Retiré des favoris" : "Ajouté aux favoris"
                            showFavoriteAlert = true
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: proteins.isFavorite(protein) ? "star.fill" : "star")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(proteins.isFavorite(protein) ? .yellow : .gray)
                            
                            Text(proteins.isFavorite(protein) ? "Favorited" : "Favorite")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(proteins.isFavorite(protein) ? Color.yellow.opacity(0.1) : Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(proteins.isFavorite(protein) ? Color.yellow.opacity(0.3) : Color(.systemGray4), lineWidth: 0.5)
                        )
                        .scaleEffect(proteins.isFavorite(protein) ? 1.02 : 1.0)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.bottom, 16)
            }
            .navigationBarTitle(Text(protein.name), displayMode: .inline)
            .navigationBarItems(trailing: btnShare)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            
            if showCardAtom {
                InfosSheet(atomSelected: $atomSelected, isPresented: $showCardAtom)
                    .frame(maxWidth: UIScreen.main.bounds.width) // Limite la largeur
                    .transition(.move(edge: .bottom))
                    .zIndex(100)
            }
            
            // Loader
            if showSpinningWheel {
                Loader(isShowing: $showSpinningWheel)
                    .zIndex(99)
            }
        }
        .clipped()
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showErrorSheet) {
            ErrorSheet(
                errorMessage: alertErrorMessage,
                isPresented: $showErrorSheet,
                onClose: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .task {
            await loadProtein()
        }
        .onChange(of: scientificMode) { _, newValue in
            if newValue {
                startParallaxMotion()
            } else {
                stopParallaxMotion()
            }
        }
        .onDisappear {
            stopParallaxMotion()
        }
        .alert("Favoris", isPresented: $showFavoriteAlert) {
            Button("OK", role: .cancel) { showFavoriteAlert = false }
        } message: {
            Text(favoriteAlertMessage)
        }
    }
    
    var btnShare: some View {
        Button(action: shareScreenshot) {
            Image(systemName: "square.and.arrow.up")
                .foregroundColor(.blue)
        }
    }
    
    func loadProtein() async {
        showSpinningWheel = true
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                if let formula = await proteins.getFormula(name: protein.name) {
                    await MainActor.run {
                        self.chemicalFormula = formula
                    }
                }
            }
            
            group.addTask {
                let result = await proteins.createScene(name: protein.name, scene: scene, showHydrogen: showHydrogen, squareHydrogenShape: squareHydrogenShape)
                await MainActor.run {
                    if !result.success {
                        self.alertErrorMessage = result.errorMessage ?? "Unknown error"
                        self.showErrorSheet = true
                    }
                }
            }
        }
        
        await MainActor.run {
            self.showSpinningWheel = false
        }
    }
    
    func shareScreenshot() {
        guard let scnView = SceneKitView.lastView else { return }
        let size = scnView.bounds.size
        let sceneImage = snapshotScene(from: scnView, size: size)
        let composited = composeBackgroundIfNeeded(sceneImage: sceneImage, size: size)
        let final = drawFormulaOverlay(on: composited, size: size)
        presentShare(image: final)
    }
    
    // MARK: - Screenshot Helpers
    
    private func snapshotScene(from scnView: SCNView, size: CGSize) -> UIImage {
#if targetEnvironment(simulator)
        let renderer = SCNRenderer(context: nil, options: nil)
#else
        let renderer = SCNRenderer(device: MTLCreateSystemDefaultDevice(), options: nil)
#endif
        renderer.scene = scnView.scene
        if let pov = scnView.pointOfView ?? scnView.defaultCameraController.pointOfView {
            renderer.pointOfView = pov
        }
        renderer.isJitteringEnabled = true
        return renderer.snapshot(atTime: 0, with: size, antialiasingMode: .multisampling4X)
    }
    
    private func composeBackgroundIfNeeded(sceneImage: UIImage, size: CGSize) -> UIImage {
        if scientificMode, let bg = UIImage(named: "ContaminationBackground") {
            let scale = scientificBackgroundScale
            let extraX = (scale - 1) * size.width / 2
            let extraY = (scale - 1) * size.height / 2
            let clampedX = min(max(parallaxOffset.width, -extraX), extraX)
            let clampedY = min(max(parallaxOffset.height, -extraY), extraY)
            return UIGraphicsImageRenderer(size: size).image { ctx in
                let rect = CGRect(origin: .zero, size: size)
                UIBezierPath(roundedRect: rect, cornerRadius: 12).addClip()
                let bgRect = CGRect(x: -extraX + clampedX, y: -extraY + clampedY, width: size.width * scale, height: size.height * scale)
                bg.draw(in: bgRect)
                sceneImage.draw(in: rect)
            }
        } else {
            return UIGraphicsImageRenderer(size: size).image { ctx in
                UIColor.systemGray6.setFill()
                ctx.fill(CGRect(origin: .zero, size: size))
                sceneImage.draw(at: .zero)
            }
        }
    }
    
    private func drawFormulaOverlay(on base: UIImage, size: CGSize) -> UIImage {
        let text = chemicalFormula
        let bottomPadding: CGFloat = 32
        let horizontalPadding: CGFloat = 16
        let maxWidth = size.width - horizontalPadding * 2
        func fittedFont(_ start: CGFloat) -> UIFont {
            var s = start
            while s > 8 {
                let f = UIFont.monospacedSystemFont(ofSize: s, weight: .semibold)
                let r = (text as NSString).boundingRect(with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: f], context: nil)
                if r.width <= maxWidth { return f }
                s -= 1
            }
            return UIFont.monospacedSystemFont(ofSize: 8, weight: .semibold)
        }
        let font = fittedFont(16)
        let paragraph = NSMutableParagraphStyle(); paragraph.alignment = .center
        let textColor: UIColor = .white
        let shadow = NSShadow(); shadow.shadowColor = UIColor.black.withAlphaComponent(0.5); shadow.shadowBlurRadius = 4; shadow.shadowOffset = CGSize(width: 0, height: 1)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: paragraph,
            .shadow: shadow
        ]
        return UIGraphicsImageRenderer(size: size).image { ctx in
            base.draw(at: .zero)
            let r = (text as NSString).boundingRect(with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attrs, context: nil)
            let origin = CGPoint(x: (size.width - r.width)/2, y: size.height - bottomPadding - r.height)
            (text as NSString).draw(in: CGRect(origin: origin, size: r.size), withAttributes: attrs)
        }
    }
    
    // MARK: - Parallax Motion Functions
    
    private func startParallaxMotion() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { data, _ in
            guard let data = data else { return }
            let attitude = data.attitude
            let roll = CGFloat(attitude.roll)
            let pitch = CGFloat(attitude.pitch)
            let targetX = max(-parallaxClamp, min(parallaxClamp, roll * parallaxFactor))
            let targetY = max(-parallaxClamp, min(parallaxClamp, pitch * parallaxFactor))
            // Anti-jitter
            if abs(targetX - parallaxOffset.width) < parallaxJitterThreshold &&
                abs(targetY - parallaxOffset.height) < parallaxJitterThreshold { return }
            // Lissage exponentiel simple
            parallaxOffset.width += (targetX - parallaxOffset.width) * parallaxSmoothing
            parallaxOffset.height += (targetY - parallaxOffset.height) * parallaxSmoothing
        }
    }
    
    private func stopParallaxMotion() {
        motionManager.stopDeviceMotionUpdates()
        parallaxOffset = .zero
    }
    
    private func presentShare(image: UIImage) {
        let av = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            window.rootViewController?.present(av, animated: true)
        }
    }
}

struct ProteinView_Previews: PreviewProvider {
    static var previews: some View {
        ProteinView(protein: Protein())
    }
}
