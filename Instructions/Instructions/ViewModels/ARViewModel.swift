import ARKit
import FirebaseFirestore
import RealityKit
import SwiftUI

class ARViewModel: NSObject, ObservableObject, UpdatesDelegate {
    @Published var editingMode = false
    @Published var imageAnchorViewPosition: CGPoint?

    @Published var text: String = ""
    @Published var image = UIImage(systemName: "circle")!

    let arView: ARViewManager

    private(set) var instructions: [Instruction] = []
    private var imageAnchor: ARImageAnchor?

    let database = Firestore.firestore()
    let storage = StorageManager()

    override init() {
        self.arView = ARViewManager(frame: .zero)
        super.init()
        uploadMedia(uiImage: UIImage(named: "qrImage")!, sceneName: "firstScene")
        arView.addReferenceImage(for: UIImage(named: "qrImage")!, name: "title", width: 8/100)
        arView.session.delegate = self
        arView.updatesDelegate = self
    }

    func didAddNewMarker(named name: String, at position: SIMD3<Float>) {
        storage.uploadEntityPosition(entityName: name, position: position)
    }

    func getPositions() {
        storage.getEntitiesPositions { entity in
            self.arView.addMarkers(for: entity)
        }
    }
    
    func uploadMedia(uiImage: UIImage, sceneName: String) {
        storage.uploadImage(image: uiImage, sceneNamePrefix: sceneName) { url in
        }
    }

    public func addMarker() {
        guard editingMode else { return }
        instructions.append(Instruction(title: "\(instructions.count)"))
        arView.addNewMarker(for: instructions.last!)
        editingMode = false
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
