//
//  SceneKitView.swift
//  SwiftyProteins
//
//  Created by Mickaël on 14/08/2025.
//


import SwiftUI
import SceneKit
import UIKit

struct SceneKitView: UIViewRepresentable {
    
    // Static variable to hold the last created SCNView for snapshot purposes
    static weak var lastView: SCNView?
    
    var view = SCNView()
    var scene: SCNScene
    @Binding var show: Bool
    @Binding var atomSelected: String
    var pointer: UnsafeMutablePointer<SCNNode>
    var protein: Protein
    
    init(scene: SCNScene, show: Binding<Bool>, atomSelected: Binding<String>, pointer: UnsafeMutablePointer<SCNNode>, protein: Protein) {
        self.scene = scene
        self._show = show
        self._atomSelected = atomSelected
        self.pointer = pointer
        self.protein = protein
        
        view.scene = self.scene
        view.allowsCameraControl = true
        view.isUserInteractionEnabled = true
        view.backgroundColor = UIColor.clear // Set transparent background for scientificMode
        view.antialiasingMode = .multisampling4X
        
        view.preferredFramesPerSecond = 60
        // Set rendersContinuously to false to optimize performance
        view.rendersContinuously = false
    }
    
    class Coordinator: NSObject {
        
        var parent: SceneKitView
        @Binding var show: Bool
        @Binding var atomSelected: String
        
        private var lastCameraPosition: SCNVector3? = nil
        private var lastCameraFOV: CGFloat? = nil
        private var lastCameraHaptic: Date = Date(timeIntervalSince1970: 0)
        private var lastCameraCheck: Date = Date(timeIntervalSince1970: 0)
        private var hapticGenerator: UIImpactFeedbackGenerator? = nil
        private var currentHapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light
        private let minimumHapticInterval: TimeInterval = 0.05 // 50ms min to avoid too frequent haptics
        
        init(_ sceneKitView: SceneKitView, show: Binding<Bool>, atomSelected: Binding<String>) {
            self.parent = sceneKitView
            self._show = show
            self._atomSelected = atomSelected
        }
        
        @objc func tapGesture(_ handleTap: UITapGestureRecognizer) {
            guard handleTap.state == .ended else { return }
            
            let view = handleTap.view as! SCNView
            let location = handleTap.location(in: view)
            let hits = view.hitTest(location, options: [
                SCNHitTestOption.boundingBoxOnly: false,
                SCNHitTestOption.firstFoundOnly: true
            ])
            
            if let tappedNode = hits.first?.node, !self.show {
                if let name = tappedNode.name, name != "atomNode" && name != "bondNode" {
                    self.atomSelected = name
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.show.toggle()
                    }
                }
            }
        }
        
        private func calculateDistance(from: SCNVector3, to: SCNVector3) -> Float {
            let dx = to.x - from.x
            let dy = to.y - from.y
            let dz = to.z - from.z
            return sqrt(dx * dx + dy * dy + dz * dz)
        }
        
        private func calculateMovementSpeed(position: SCNVector3, fov: CGFloat, deltaTime: TimeInterval) -> Double {
            guard let lastPos = self.lastCameraPosition,
                  let lastFOV = self.lastCameraFOV,
                  deltaTime > 0 else { return 0.0 }
            
            let distance = calculateDistance(from: lastPos, to: position)
            let fovDelta = abs(fov - lastFOV)
            
            let positionSpeed = Double(distance) / deltaTime
            let fovSpeed = Double(fovDelta) / deltaTime
            
            return max(positionSpeed, fovSpeed)
        }
        
        private func getHapticSettings(speed: Double) -> (intensity: UIImpactFeedbackGenerator.FeedbackStyle, interval: TimeInterval) {
            switch speed {
            case 0...0.5:
                return (.light, 2.0)
            case 0.5...2.0:
                return (.light, 0.8)
            case 2.0...5.0:
                return (.light, 0.4)
            case 5.0...10.0:
                return (.medium, 0.2)
            case 10.0...20.0:
                return (.medium, 0.1)
            case 20.0...40.0:
                return (.heavy, 0.06)
            default:
                return (.heavy, 0.05)
            }
        }
        
        func observeCamera(sceneView: SCNView) {
            currentHapticStyle = .light
            hapticGenerator = UIImpactFeedbackGenerator(style: currentHapticStyle)
            hapticGenerator?.prepare()
            
            Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
                self?.updateCameraObserver(sceneView: sceneView)
            }
        }
        
        private func updateCameraObserver(sceneView: SCNView) {
            guard let cameraNode = sceneView.pointOfView else { return }
            
            let now = Date()
            let currentPosition = cameraNode.position
            let currentFOV = cameraNode.camera?.fieldOfView ?? 0
            let deltaTime = now.timeIntervalSince(self.lastCameraCheck)
            
            self.lastCameraCheck = now
            
            guard let lastPos = lastCameraPosition, let lastFOV = lastCameraFOV else {
                self.lastCameraPosition = currentPosition
                self.lastCameraFOV = currentFOV
                return
            }
            
            let positionDelta = calculateDistance(from: lastPos, to: currentPosition)
            let fovDelta = abs(currentFOV - lastFOV)
            
            let hasPositionMovement = positionDelta > 0.01
            let hasFOVMovement = fovDelta > 0.5
            
            guard hasPositionMovement || hasFOVMovement else {
                self.lastCameraPosition = currentPosition
                self.lastCameraFOV = currentFOV
                return
            }
            
            let speed = calculateMovementSpeed(position: currentPosition, fov: currentFOV, deltaTime: deltaTime)
            
            let hapticSettings = getHapticSettings(speed: speed)
            
            let timeSinceLastHaptic = now.timeIntervalSince(self.lastCameraHaptic)
            let requiredInterval = max(hapticSettings.interval, minimumHapticInterval)
            
            if timeSinceLastHaptic >= requiredInterval {
                if currentHapticStyle != hapticSettings.intensity {
                    hapticGenerator = UIImpactFeedbackGenerator(style: hapticSettings.intensity)
                    currentHapticStyle = hapticSettings.intensity
                    hapticGenerator?.prepare()
                }
                
                hapticGenerator?.impactOccurred()
                self.lastCameraHaptic = now
            }
            
            self.lastCameraPosition = currentPosition
            self.lastCameraFOV = currentFOV
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self, show: $show, atomSelected: $atomSelected)
    }
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = self.view
        
        let gestureTap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapGesture(_:)))
        gestureTap.numberOfTapsRequired = 1
        gestureTap.numberOfTouchesRequired = 1
        sceneView.addGestureRecognizer(gestureTap)
        
        context.coordinator.observeCamera(sceneView: sceneView)
        
        setupCamera(sceneView: sceneView)
        
        // Enregistre la vue pour les snapshots
        SceneKitView.lastView = sceneView
        
        return sceneView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.scene = scene
        
        if let pov = scnView.defaultCameraController.pointOfView {
            pointer.initialize(to: pov)
        }
    }
    
    private func setupCamera(sceneView: SCNView) {
        if let cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true) {
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        } else {
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
            cameraNode.name = "camera"
            scene.rootNode.addChildNode(cameraNode)
        }
    }
}
