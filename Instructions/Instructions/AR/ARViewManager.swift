import ARKit
import FirebaseFirestore
import RealityKit
import SwiftUI

protocol UpdatesDelegate {
    func didAddNewMarker(named name: String, at position: SIMD3<Float>)
    func getPositions()
}

class ARViewManager: ARView {
    var updatesDelegate: UpdatesDelegate?
    var count = 1 // temp

    /// stores as children all entities added to the scene
    private var rootAnchorEntity = AnchorEntity()
    private var imageAnchorToEntity: [ARImageAnchor: AnchorEntity] = [:]
    private var newReferenceImages: Set<ARReferenceImage> = []
    private let database = Firestore.firestore()

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

        updatesDelegate?.getPositions()
    }

    public func addMarkers(for markerEntities: [MarkerEntity]){
        markerEntities.forEach { entity in
            addMarker(for: entity)
        }
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
    public func addNewMarker(for instruction: Instruction) {
        let newEntity = generateModelEntity(withName: "new entity \(count)")
        attachEntityToCameraAnchor(entity: newEntity)
        rootAnchorEntity.addChild(newEntity, preservingWorldTransform: true)
        instruction.setMarkerEntity(newEntity)
        count += 1

        updatesDelegate?.didAddNewMarker(named: newEntity.name, at: newEntity.position)
    }

    public func addMarker(for markerEntity: MarkerEntity) {
        let instruction = Instruction(title: "from firebase") // temp
        let newEntity =  generateModelEntity(withName: "firebase \(markerEntity.name)")
        newEntity.position = SIMD3<Float>(x: markerEntity.x, y: markerEntity.y, z: markerEntity.z)
        rootAnchorEntity.addChild(newEntity)
        instruction.setMarkerEntity(newEntity)
        count += 1
    }

    private func attachEntityToCameraAnchor(entity: ModelEntity) {
        let cameraAnchor = AnchorEntity(.camera)
        cameraAnchor.name = "CameraAnchor"
        cameraAnchor.addChild(entity)
        entity.position.z = -0.25
        self.scene.addAnchor(cameraAnchor)
    }

    private func generateModelEntity(withName name: String) -> ModelEntity {
        let newEntity = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.01))
        newEntity.name = name
        return newEntity
    }

    private func finalochkaEntity(for instruction: Instruction, entity: ModelEntity) {
        rootAnchorEntity.addChild(entity, preservingWorldTransform: true)
        instruction.setMarkerEntity(entity)
    }
}
