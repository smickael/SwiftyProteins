//
//  Proteins.swift
//  SwiftyProteins
//
//  Created by Mickaël on 14/08/2025.
//

import SceneKit
import SwiftUI

let CPKColor: [String: UIColor] = [
    "H": UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1),         // Hydrogène - Blanc
    "C": UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1),         // Carbone - Noir
    "N": UIColor(red: 0.188, green: 0.314, blue: 0.973, alpha: 1),   // Azote - Bleu clair
    "O": UIColor(red: 1.0, green: 0.051, blue: 0.051, alpha: 1),     // Oxygène - Rouge
    "F": UIColor(red: 0.565, green: 0.933, blue: 0.565, alpha: 1),   // Fluor - Vert clair
    "CL": UIColor(red: 0.122, green: 0.941, blue: 0.122, alpha: 1),  // Chlore - Vert
    "BR": UIColor(red: 0.651, green: 0.161, blue: 0.161, alpha: 1),  // Brome - Rouge brun
    "I": UIColor(red: 0.580, green: 0.0, blue: 0.580, alpha: 1),     // Iode - Violet foncé
    "HE": UIColor(red: 0.851, green: 1.0, blue: 1.0, alpha: 1),      // Hélium - Bleu très pâle
    "NE": UIColor(red: 0.702, green: 0.890, blue: 0.961, alpha: 1),  // Néon - Bleu pâle
    "AR": UIColor(red: 0.502, green: 0.819, blue: 0.890, alpha: 1),  // Argon - Bleu cyan
    "XE": UIColor(red: 0.259, green: 0.619, blue: 0.690, alpha: 1),  // Xénon - Bleu gris
    "KR": UIColor(red: 0.361, green: 0.722, blue: 0.820, alpha: 1),  // Krypton - Bleu moyen
    "P": UIColor(red: 1.0, green: 0.502, blue: 0.0, alpha: 1),       // Phosphore - Orange
    "S": UIColor(red: 1.0, green: 1.0, blue: 0.188, alpha: 1),       // Soufre - Jaune
    "B": UIColor(red: 1.0, green: 0.710, blue: 0.710, alpha: 1),     // Bore - Rose pâle
    "LI": UIColor(red: 0.800, green: 0.502, blue: 1.0, alpha: 1),    // Lithium - Violet pâle
    "NA": UIColor(red: 0.671, green: 0.361, blue: 0.949, alpha: 1),  // Sodium - Violet
    "K": UIColor(red: 0.561, green: 0.251, blue: 0.831, alpha: 1),   // Potassium - Violet foncé
    "RB": UIColor(red: 0.439, green: 0.180, blue: 0.690, alpha: 1),  // Rubidium - Violet foncé
    "CS": UIColor(red: 0.341, green: 0.090, blue: 0.561, alpha: 1),  // Césium - Violet très foncé
    "FR": UIColor(red: 0.259, green: 0.0, blue: 0.400, alpha: 1),    // Francium - Violet noir
    "BE": UIColor(red: 0.761, green: 1.0, blue: 0.0, alpha: 1),      // Béryllium - Vert citron
    "MG": UIColor(red: 0.541, green: 1.0, blue: 0.0, alpha: 1),      // Magnésium - Vert clair
    "CA": UIColor(red: 0.239, green: 1.0, blue: 0.0, alpha: 1),      // Calcium - Vert moyen
    "SR": UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1),        // Strontium - Vert
    "BA": UIColor(red: 0.0, green: 0.788, blue: 0.0, alpha: 1),      // Baryum - Vert foncé
    "RA": UIColor(red: 0.0, green: 0.502, blue: 0.0, alpha: 1),      // Radium - Vert très foncé
    "TI": UIColor(red: 0.749, green: 0.761, blue: 0.780, alpha: 1),  // Titane - Gris
    "FE": UIColor(red: 0.878, green: 0.400, blue: 0.200, alpha: 1),  // Fer - Orange brun
    "PT": UIColor(red: 0.815, green: 0.815, blue: 0.878, alpha: 1),  // Platine - Gris bleu
]

struct Protein: Identifiable {
    var id: NSNumber
    var name: String
    
    init() {
        self.id = NSNumber(0)
        self.name = "default"
    }
    
    init(id: NSNumber, name: String) {
        self.id = id
        self.name = name
    }
}

// Struct to hold atoms and bonds data
private struct MoleculeData {
    var atoms: [Int: AtomInfo] = [:]
    var bonds: [(Int, Int)] = []
    
    struct AtomInfo {
        let position: SCNVector3
        let element: String
        let isHydrogen: Bool
    }
}

class Proteins: ObservableObject {
    @Published var proteins: [Protein]
    @Published var isUnlocked: Bool = false
    @Published var favorites: [Protein] = [] {
        didSet {
            saveFavorites()
        }
    }
    
    init(file: String) {
        self.proteins = [Protein]()
        if let fileUrl = Bundle.main.url(forResource: file, withExtension: ".txt") {
            if let fileContent = try? String(contentsOf: fileUrl, encoding: .utf8) {
                let proteinsTable = fileContent.components(separatedBy: .newlines).filter({ $0 != "" })
                for (index, proteinsName) in proteinsTable.enumerated() {
                    let newProtein = Protein(id: NSNumber(value: index), name: proteinsName)
                    self.proteins.append(newProtein)
                }
            }
        }
        loadFavorites()
    }
    
    func getFormula(name: String) async -> String? {
        guard let url = URL(string: "https://files.rcsb.org/ligands/view/\(name.uppercased()).cif") else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let file = String(data: data, encoding: .utf8) ?? ""
            
            if let line = file.components(separatedBy: .newlines)
                .first(where: { $0.contains("_chem_comp.formula") }),
               let range = line.range(of: "\".*?\"", options: .regularExpression) {
                return String(line[range]).replacingOccurrences(of: "\"", with: "")
            }
        } catch {
            print("Error fetching formula: \(error)")
        }
        
        return nil
    }
    
    // Create Scene from SDF file
    func createScene(name: String, scene: SCNScene, showHydrogen: Bool = true, squareHydrogenShape: Bool = false) async -> (success: Bool, errorMessage: String?) {
        guard let url = URL(string: "https://files.rcsb.org/ligands/view/\(name.uppercased())_ideal.sdf") else {
            return (false, "Invalid URL for \(name)")
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let fileContent = String(data: data, encoding: .utf8) else {
                return (false, "Cannot decode file for \(name)")
            }
            
            // Find V2000 line
            let lines = fileContent.components(separatedBy: .newlines)
            var v2000Line = ""
            var v2000Index = -1
            
            for (i, line) in lines.enumerated() {
                if line.hasSuffix("V2000") {
                    v2000Line = line
                    v2000Index = i
                    break
                }
            }
            
            // Strict check: V2000 line must be present
            guard v2000Index >= 0 else {
                let errorMsg = """
❌ SDF invalid file: missing V2000 line

📋 Expected format :
[atoms_nb] [bonds_nb]  0  0  0  0  0999 V2000
Example : 12    11  0  0  0  0  0  0  0999 V2000

🔍 Found line : \(v2000Line.isEmpty ? "none" : v2000Line)
"""
                return (false, errorMsg)
            }
            
            // Parse atom and bond counts
            let parts = v2000Line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            guard parts.count >= 2,
                  let atomCount = Int(parts[0]),
                  let bondCount = Int(parts[1]),
                  atomCount > 0 else {
                let errorMsg = """
❌ Invalid counters in SDF file

📋 Expected format :
[atoms_nb] [bonds_nb]  0  0  0  0  0999 V2000
Example : 12    11  0  0  0  0  0  0  0999 V2000

🔍 Found line :
\(v2000Line)
"""
                return (false, errorMsg)
            }
            
            // Strict check: ensure enough lines for atoms and bonds
            let requiredLines = v2000Index + 1 + atomCount + bondCount
            guard lines.count >= requiredLines else {
                let errorMsg = """
❌ SDF truncated file

📋 Expected format :
[atoms_nb] [bonds_nb]  0  0  0  0  0999 V2000
Example : 12    11  0  0  0  0  0  0  0999 V2000

🔍 Found line :
\(v2000Line)

📊 Statistics :
• Expected atoms : \(atomCount)
• Expected bonds : \(bondCount)  
• Available lines : \(lines.count)
• Required lines : \(requiredLines)
"""
                return (false, errorMsg)
            }
            
            // Parse datas
            let moleculeData = await parseMoleculeData(from: fileContent, atomCount: atomCount, bondCount: bondCount, v2000Index: v2000Index)
            
            // Strict check: parsed atom count must match expected
            guard moleculeData.atoms.count == atomCount else {
                let errorMsg = """
❌ Error parsing SDF file

📋 Expected format :
[atoms_nb] [bonds_nb]  0  0  0  0  0999 V2000
Example : 12    11  0  0  0  0  0  0  0999 V2000

🔍 Found line :
\(v2000Line)

📊 Parsing results :
• Expected atoms : \(atomCount)
• Parsed atoms : \(moleculeData.atoms.count)
"""
                return (false, errorMsg)
            }
            
            await buildScene(scene: scene, data: moleculeData, showHydrogen: showHydrogen, squareHydrogenShape: squareHydrogenShape)
            return (true, nil)
            
        } catch {
            return (false, "Network Error : \(error.localizedDescription)")
        }
    }
    
    // Optimized parsing of molecular data
    private func parseMoleculeData(from content: String, atomCount: Int, bondCount: Int, v2000Index: Int) async -> MoleculeData {
        return await withCheckedContinuation { continuation in
            Task {
                var data = MoleculeData()
                let lines = content.components(separatedBy: .newlines)
                
                // Atoms parsing (strictly defined lines)
                for i in 0..<atomCount {
                    let lineIndex = v2000Index + 1 + i
                    guard lineIndex < lines.count else { break }
                    
                    let line = lines[lineIndex]
                    if let atomInfo = parseAtomLine(line, index: i + 1) {
                        data.atoms[i + 1] = atomInfo
                    }
                }
                
                // Bonds parsing (strictly defined lines)
                for i in 0..<bondCount {
                    let lineIndex = v2000Index + 1 + atomCount + i
                    guard lineIndex < lines.count else { break }
                    
                    let line = lines[lineIndex]
                    if let bond = parseBondLine(line) {
                        data.bonds.append(bond)
                    }
                }
                
                continuation.resume(returning: data)
            }
        }
    }
    
    // Create Scene
    @MainActor
    private func buildScene(scene: SCNScene, data: MoleculeData, showHydrogen: Bool, squareHydrogenShape: Bool) {
        // Clear previous nodes
        scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
        
        let atomNode = SCNNode()
        let bondNode = SCNNode()
        atomNode.name = "atomNode"
        bondNode.name = "bondNode"
        
        // Create atoms
        for (_, atomInfo) in data.atoms {
            if !showHydrogen && atomInfo.isHydrogen {
                continue
            }
            
            let atom = createAtom(position: atomInfo.position, element: atomInfo.element, squareShape: squareHydrogenShape && atomInfo.isHydrogen)
            atomNode.addChildNode(atom)
        }
        
        // Create bonds (excluding those with hydrogen if necessary)
        for (atom1, atom2) in data.bonds {
            guard let atomInfo1 = data.atoms[atom1],
                  let atomInfo2 = data.atoms[atom2] else { continue }
            
            if !showHydrogen && (atomInfo1.isHydrogen || atomInfo2.isHydrogen) {
                continue
            }
            
            let bond = createBond(from: atomInfo1.position, to: atomInfo2.position)
            bondNode.addChildNode(bond)
        }
        
        scene.rootNode.addChildNode(atomNode)
        scene.rootNode.addChildNode(bondNode)
        setupLighting(scene: scene)
    }
    
    // Helpers
    private func parseAtomLine(_ line: String, index: Int) -> MoleculeData.AtomInfo? {
        guard line.count >= 34 else { return nil }
        
        let x = String(line.prefix(10)).trimmingCharacters(in: .whitespaces)
        let y = String(line.dropFirst(10).prefix(10)).trimmingCharacters(in: .whitespaces)
        let z = String(line.dropFirst(20).prefix(10)).trimmingCharacters(in: .whitespaces)
        let element = String(line.dropFirst(31).prefix(3)).trimmingCharacters(in: .whitespaces)
        
        guard let xVal = Double(x),
              let yVal = Double(y),
              let zVal = Double(z) else { return nil }
        
        return MoleculeData.AtomInfo(
            position: SCNVector3(xVal, yVal, zVal),
            element: element,
            isHydrogen: element.uppercased() == "H"
        )
    }
    
    private func parseBondLine(_ line: String) -> (Int, Int)? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        let parts = trimmed.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        
        guard parts.count >= 2,
              let atom1 = Int(parts[0]),
              let atom2 = Int(parts[1]) else { return nil }
        
        return (atom1, atom2)
    }
    
    private func createAtom(position: SCNVector3, element: String, squareShape: Bool = false) -> SCNNode {
        let sphere = SCNSphere(radius: 0.3)
        let node = SCNNode(geometry: sphere)
        node.position = position
        node.name = element
        
        let color = CPKColor[element.uppercased()] ?? UIColor(red: 0.86, green: 0.46, blue: 1, alpha: 1)
        node.geometry?.firstMaterial?.diffuse.contents = color
        
        if squareShape {
            // Apply square shape to hydrogen atom
            let box = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0)
            node.geometry = box
        }
        
        return node
    }
    
    private func createBond(from: SCNVector3, to: SCNVector3) -> SCNNode {
        let direction = SCNVector3(to.x - from.x, to.y - from.y, to.z - from.z)
        let length = sqrt(direction.x * direction.x + direction.y * direction.y + direction.z * direction.z)
        
        let cylinder = SCNCylinder(radius: 0.08, height: CGFloat(length))
        let node = SCNNode(geometry: cylinder)
        
        node.position = SCNVector3(
            (from.x + to.x) / 2,
            (from.y + to.y) / 2,
            (from.z + to.z) / 2
        )
        
        if length > 0 {
            node.eulerAngles = SCNVector3(
                Float.pi / 2,
                acos(direction.z / length),
                atan2(direction.y, direction.x)
            )
        }
        
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.systemGray
        return node
    }
    
    private func setupLighting(scene: SCNScene) {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
    }
    
    // Handle favorites
    func toggleFavorite(_ protein: Protein) {
        if let index = favorites.firstIndex(where: { $0.id == protein.id }) {
            favorites.remove(at: index)
        } else {
            favorites.append(protein)
        }
    }
    
    func isFavorite(_ protein: Protein) -> Bool {
        favorites.contains(where: { $0.id == protein.id })
    }
    
    private func saveFavorites() {
        let ids = favorites.map { $0.id.intValue }
        UserDefaults.standard.set(ids, forKey: "favorites")
    }
    
    func loadFavorites() {
        let ids = UserDefaults.standard.array(forKey: "favorites") as? [Int] ?? []
        favorites = proteins.filter { ids.contains($0.id.intValue) }
    }
}

