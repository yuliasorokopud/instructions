import ARKit
import FirebaseFirestore
import RealityKit
import SwiftUI

class ARViewModel: NSObject, ObservableObject, UpdatesDelegate {
    @Published var editingMode = false
    @Published var imageAnchorViewPosition: CGPoint?

    // temp
    @Published var image = UIImage(systemName: "circle")!

    let arView: ARViewManager

    private let database = Firestore.firestore()
    private let storage = StorageManager()

    private(set) var instructions: [Instruction] = []
    private var imageAnchor: ARImageAnchor?
    private var temporaryInstruction: Instruction?

    override init() {
        self.arView = ARViewManager(frame: .zero)
        super.init()

        // TODO: - image from firebase
        arView.addReferenceImage(for: UIImage(named: "qrImage")!, name: "title", width: 8/100)
        
        arView.session.delegate = self
        arView.updatesDelegate = self

        getInstructions()
    }

    public func addMarker(for instruction: Instruction) {
        guard editingMode else { return }
        instructions.append(instruction)
        storage.uploadNewInstruction(instruction: instruction)
        arView.addNewMarker(for: instructions.last!)
        editingMode = false
    }

    func didAddNewMarkerNamed(_ name: String, at position: SIMD3<Float>, instructionId instId: String) {
        storage.uploadEntityPosition(entityName: name, position: position, instId: instId)
    }

    func getSavedEntitiesPositions() {
        storage.retrieveEntitiesPositions {
            self.arView.addMarkers(for: $0, instructions: self.instructions)
        }
    }

    func clearScene() {
        instructions.removeAll()
        imageAnchorViewPosition = nil
        arView.clear()
        storage.clearScene()
    }

    func getInstructions() {
        storage.retrieveInstructions { instructions in
            self.instructions = instructions
        }
    }
    
    func uploadMedia(uiImage: UIImage, sceneName: String) {
        storage.uploadImage(image: uiImage, sceneNamePrefix: sceneName) { url in
        }
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
            arView.addRootAnchorEntity(for: $0)
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
}
