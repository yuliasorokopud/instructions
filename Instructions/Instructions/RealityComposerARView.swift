import ARKit
import RealityKit
import SwiftUI

class RealityComposerARView: ARView {
    let boxAnchor = try! MyScene.loadBox()
    var imageAnchorToEntity: [ARImageAnchor: AnchorEntity] = [:]

    internal required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        self.session.delegate = self
        configure()
    }

    @MainActor required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        self.scene.anchors.append(boxAnchor)
    }
}

extension RealityComposerARView: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        anchors.compactMap { $0 as? ARImageAnchor }.forEach {
            let anchorEntity = AnchorEntity()
            guard let modelEntity = boxAnchor.steelBox else { return }
            anchorEntity.addChild(modelEntity)
            self.scene.addAnchor(anchorEntity)
            anchorEntity.transform.matrix = $0.transform
            imageAnchorToEntity[$0] = anchorEntity
        }
    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        anchors.compactMap { $0 as? ARImageAnchor }.forEach {
            let anchorEntity = imageAnchorToEntity[$0]
            anchorEntity?.transform.matrix = $0.transform
        }
    }
}
