import ARKit
import RealityKit
import SwiftUI

class ARViewManager: ARView {
    /// stores as children all entities added to the scene
    private var rootEntity = AnchorEntity()
    private var imageAnchorToEntity: [ARAnchor: AnchorEntity] = [:]

    internal required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        // temporary image anchor
        let imageAnchorEntity = AnchorEntity(.image(group: "AR Resources", name: "qrImage"))
        self.scene.anchors.append(imageAnchorEntity)
    }

    @MainActor required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func addRootEntity(for imageAnchor: ARImageAnchor) {
        self.scene.addAnchor(rootEntity)
        self.imageAnchorToEntity[imageAnchor] = rootEntity
    }

    public func getImageAnchorPosition(of anchor: ARImageAnchor) -> CGPoint? {
        let translation = SIMD3<Float>(
            x: anchor.transform.columns.3.x,
            y: anchor.transform.columns.3.y,
            z: anchor.transform.columns.3.z
        )

        guard let point = self.project(translation) else {
            return nil
        }

        return CGPoint(x: abs(point.x), y: abs(point.y))
    }

    public func updateEntityForImageAnchor(_ anchor: ARImageAnchor) {
        let anchorEntity = imageAnchorToEntity[anchor]
        anchorEntity?.transform.matrix = anchor.transform
    }

    /// add new model entity to the scene (adding sphere in front of camera)
    public func addMarker() {
        let newEntity = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.01))
        newEntity.name = "new entity"
        let cameraAnchor = AnchorEntity(.camera)
        cameraAnchor.name = "CameraAnchor"
        cameraAnchor.addChild(newEntity)
        newEntity.position.z = -0.25
        self.scene.addAnchor(cameraAnchor)
        rootEntity.addChild(newEntity, preservingWorldTransform: true)
    }
}
