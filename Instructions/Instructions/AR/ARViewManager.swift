import ARKit
import RealityKit
import SwiftUI

class ARViewManager: ARView {
    /// stores as children all entities added to the scene
    private var rootAnchorEntity = AnchorEntity()
    private var imageAnchorToEntity: [ARImageAnchor: AnchorEntity] = [:]

    private var newReferenceImages: Set<ARReferenceImage> = []

    internal required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
    }

    @MainActor required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func addReferenceImage(for image: UIImage, name: String, width: CGFloat) {
        guard let cgImage = image.cgImage else { return }
        let referenceImage = ARReferenceImage(cgImage, orientation: .up, physicalWidth: width)
        referenceImage.name = name

        self.newReferenceImages.removeAll()
        self.newReferenceImages.insert(referenceImage)

        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = self.newReferenceImages
        self.session.run(configuration)
    }

    public func addRootAnchorEntity(for imageAnchor: ARImageAnchor) {
        let imageAnchorEntity = AnchorEntity(anchor: imageAnchor)
        self.scene.anchors.append(imageAnchorEntity)
        self.scene.addAnchor(rootAnchorEntity)
        self.imageAnchorToEntity[imageAnchor] = rootAnchorEntity
    }

    public func imageAnchorPosition(of anchor: ARImageAnchor) -> CGPoint? {
        let translation = SIMD3<Float>(
            x: anchor.transform.columns.3.x,
            y: anchor.transform.columns.3.y,
            z: anchor.transform.columns.3.z
        )

        guard let point = self.project(translation) else {
            return nil
        }

        return point
    }

    public func updateEntityForImageAnchor(_ anchor: ARImageAnchor) {
        let anchorEntity = imageAnchorToEntity[anchor]
        anchorEntity?.transform.matrix = anchor.transform
    }

    /// add new model entity to the scene (adding sphere in front of camera)
    public func addMarker(for instruction: Instruction) {
        let newEntity = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.01))
        newEntity.name = "new entity \(count)"
        let cameraAnchor = AnchorEntity(.camera)
        cameraAnchor.name = "CameraAnchor"
        cameraAnchor.addChild(newEntity)
        newEntity.position.z = -0.25
        self.scene.addAnchor(cameraAnchor)
        rootAnchorEntity.addChild(newEntity, preservingWorldTransform: true)
        instruction.setMarkerEntity(newEntity)
        count += 1
    }
    var count = 1
}


//      po imageAnchorToEntity.first?.value.children[2]
