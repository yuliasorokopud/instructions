import ARKit
import FirebaseFirestore
import RealityKit
import SwiftUI

class ARViewModel: NSObject, ObservableObject {
    @Published private(set) var instructions: [Instruction] = []
    @Published var editingMode = false
    @Published var imageAnchorViewPosition: CGPoint?

    let arView: ARViewManager
    let scene: ARScene

    private let storageManager = StorageManager()

    private var imageAnchor: ARImageAnchor?
    private var temporaryInstruction: Instruction?

    init(scene: ARScene) {
        self.arView = ARViewManager(frame: .zero)
        self.scene = scene
        super.init()
        arView.session.delegate = self
        addImageReference(scene: scene)
        getInstructions()
    }

    public func addMarker(for instruction: Instruction) {
        guard editingMode else { return }
        instructions.append(instruction)
        storageManager.uploadNewInstruction(instruction: instruction, toSceneWithId: scene.id)
        arView.addNewMarker(for: instruction) {
            guard let marker = instruction.markerEntity else { return }
            storageManager.uploadEntity(marker, instId: instruction.id)
        }
        editingMode = false
    }

    public func updateInstruction(_ instruction: Instruction) {
        storageManager.uploadNewInstruction(instruction: instruction, toSceneWithId: scene.id)
        editingMode = false
    }

    func getSavedEntitiesPositions() {
        storageManager.retrieveEntitiesPositions {
            self.arView.addMarkers(for: $0, instructions: self.instructions)
        }
    }

    func deleteInstruction(_ instruction: Instruction) {
        storageManager.deleteInstruction(instruction)
        if let index = instructions.firstIndex(where: { $0.id == instruction.id }) {
            instructions.remove(at: index)
        }
    }

    func clearScene() {
        instructions.removeAll()
        imageAnchorViewPosition = nil
        arView.clearScene()
        storageManager.deleteAllInstructionsOnTheScene(scene)
    }

    func quitArSession() {
        arView.quitScene()
    }

    func getInstructions() {
        storageManager.retrieveInstructions(for: scene) { instructions in
            self.instructions = instructions
        }
    }
    
    func addImageReference(scene: ARScene) {
        guard let uiImage = scene.anchorImage else {
            fatalError("failed to unwrap optional image")
        }
        arView.addReferenceImage(for: uiImage, name: scene.name, width: CGFloat(Float(scene.anchorImageWidth)!)/100)
    }

    private func updateInstructionsPositions() {
        self.instructions.indices.forEach {
            guard let markerEntity = instructions[$0].markerEntity,
                  let updatedPoint = arView.project(markerEntity.position(relativeTo: nil))
            else { return }
            
            instructions[$0].setMarkerScreenPosition(point: CGPoint(x: updatedPoint.x - 15, y: updatedPoint.y - 60)
            )
        }
    }
}

// MARK: - ARSessionDelegate

extension ARViewModel: ARSessionDelegate {
    /// Set rootAnchorEntity to ARImageAnchor 
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        anchors.compactMap { $0 as? ARImageAnchor }.forEach {
            imageAnchor = $0
            arView.addRootAnchorEntity(for: $0) {
                getSavedEntitiesPositions()
            }
        }
    }
    
    /// tracking image anchor transtorm and updating entities
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        anchors.compactMap { $0 as? ARImageAnchor }.forEach {
            arView.updateEntityForImageAnchor($0)
            self.imageAnchor = $0
        }
    }

    /// updating image anchor's and instructions' view positions
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if let imageAnchor = imageAnchor {
            self.imageAnchorViewPosition = arView.imageAnchorPosition(of: imageAnchor)
            updateInstructionsPositions()
        }
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        arView.reConfig()
    }
}
