import ARKit
import RealityKit
import SwiftUI

class ARViewModel: NSObject, ObservableObject {
    @Published var editingMode = false
    @Published var imageAnchorViewPosition: CGPoint?

    @Published var text: String = ""
    @Published var image = UIImage(systemName: "circle")!

    let arView: ARViewManager

    private(set) var instructions: [Instruction] = []
    private var imageAnchor: ARImageAnchor?

    override init() {
        self.arView = ARViewManager(frame: .zero)
        super.init()
        uploadMedia(uiImage: UIImage(named: "qrImage")!, sceneName: "firstScene")
        arView.session.delegate = self
    }

    func uploadMedia(uiImage: UIImage, sceneName: String) {
        let sm = StorageManager()
        sm.uploadImage(image: uiImage, sceneNamePrefix: sceneName) { url in
        }
    }

    public func addMarker() {
        guard editingMode else { return }
        instructions.append(Instruction(title: "\(instructions.count)"))
        arView.addMarker(for: instructions.last!)
        editingMode = false
    }

    private func updateInstructionsPositions() {
        self.instructions.indices.forEach {
            if let markerEntity = instructions[$0].markerEntity,
               let updatedPoint = arView.project(markerEntity.position(relativeTo: nil))
            {
                instructions[$0].setMarkerScreenPosition(point: CGPoint(x: updatedPoint.x - 15, y: updatedPoint.y - 60)
                )
//                print("entity position: \(updatedPoint)")
//                print("marker entity position: \(markerEntity.position)")
            }
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
//            print("anchor position: \(imageAnchorViewPosition)")
        }
    }
}
