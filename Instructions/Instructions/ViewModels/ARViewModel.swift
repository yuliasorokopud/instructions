import ARKit
import RealityKit
import SwiftUI

class ARViewModel: NSObject, ObservableObject {
    @Published public var editingMode = false
    @Published var imageAnchorScreenPosition: CGPoint?

    let arView: ARViewManager

    private var imageAnchor: ARImageAnchor?

    override init() {
        self.arView = ARViewManager(frame: .zero)
        super.init()
        arView.session.delegate = self
    }

    public func addMarker() {
        guard editingMode else { return }
        arView.addMarker()
        editingMode = false
    }
}

// MARK: - ARSessionDelegate

extension ARViewModel: ARSessionDelegate {
    /// Create AnchorEntity from each ARImageAnchor
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        anchors.compactMap { $0 as? ARImageAnchor }.forEach {
            imageAnchor = $0
            arView.addRootEntity(for: $0)
        }
    }
    
    /// tracking image anchor transtorm and updating entities
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        anchors.compactMap { $0 as? ARImageAnchor }.forEach {
            arView.updateEntityForImageAnchor($0)
            self.imageAnchor = $0
        }
    }

    /// updating image anchor position (CGPoint)
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if let imageAnchor = imageAnchor {
            self.imageAnchorScreenPosition =  arView.getImageAnchorPosition(of: imageAnchor)
//            print("anchor position: \(imageAnchorScreenPosition)")
        }
    }
}
