import ARKit
import FirebaseFirestore
import RealityKit
import SwiftUI

class ARViewManager: ARView {
    /// stores as children all entities added to the scene
    private var rootAnchorEntity: AnchorEntity?
    private var imageAnchorToEntity: [ARImageAnchor: AnchorEntity] = [:]
    private var newReferenceImages: Set<ARReferenceImage> = []
    private let configuration = ARWorldTrackingConfiguration()

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

        configure()
    }

    func configure() {
        configuration.detectionImages = self.newReferenceImages
        self.session.run(configuration)
    }

    func reConfig() {
        session.run(session.configuration ?? ARWorldTrackingConfiguration(), options: [.resetTracking])
    }

    public func addRootAnchorEntity(for imageAnchor: ARImageAnchor, completion: () -> Void) {
        rootAnchorEntity = AnchorEntity()
        let imageAnchorEntity = AnchorEntity(anchor: imageAnchor)
        self.scene.anchors.append(imageAnchorEntity)
        self.scene.addAnchor(rootAnchorEntity!)
        self.imageAnchorToEntity[imageAnchor] = rootAnchorEntity

        completion()
    }

    public func imageAnchorPosition(of anchor: ARImageAnchor) -> CGPoint? {
        let translation = SIMD3<Float>(
            x: anchor.transform.columns.3.x,
            y: anchor.transform.columns.3.y,
            z: anchor.transform.columns.3.z
        )

        return self.project(translation)
    }

    func quitScene() {
        rootAnchorEntity?.removeFromParent()
        rootAnchorEntity = nil
        session.pause()
    }

    func clearScene() {
        rootAnchorEntity?.children.removeAll()
        configure()
    }

    public func updateEntityForImageAnchor(_ anchor: ARImageAnchor) {
        let anchorEntity = imageAnchorToEntity[anchor]
        anchorEntity?.transform.matrix = anchor.transform
    }

    /// add new model entity to the scene (adding sphere in front of camera)
    public func addNewMarker(for instruction: Instruction, completion: () -> Void) {
        let newEntity = generateModelEntity(withName: instruction.title)
        attachEntityToCameraAnchor(entity: newEntity)
        rootAnchorEntity?.addChild(newEntity, preservingWorldTransform: true)
        instruction.setMarkerEntity(newEntity)
        completion()
        print("added with name \(newEntity.name)")
    }

    /// add array of marker entities fetched from firebase
    public func addMarkers(for markerEntities: [MarkerEntity], instructions: [Instruction]) {
        markerEntities.forEach { entity in
            guard let instr = instructions.first(where: { $0.id == entity.instructionId })
            else { return }

            addMarker(for: instr, markerEntity: entity)
        }
    }

    /// add marker fetched from firebase
    public func addMarker(for instruction: Instruction, markerEntity: MarkerEntity) {
        let newEntity =  generateModelEntity(withName: markerEntity.name)
        newEntity.position = SIMD3<Float>(x: markerEntity.x,
                                          y: markerEntity.y,
                                          z: markerEntity.z)
        rootAnchorEntity?.addChild(newEntity)
        instruction.setMarkerEntity(newEntity)
        print("added with name \(newEntity.name) from firebase")
    }

    private func attachEntityToCameraAnchor(entity: ModelEntity) {
        let cameraAnchor = AnchorEntity(.camera)
        cameraAnchor.name = "CameraAnchor"
        cameraAnchor.addChild(entity)
        entity.position.z = -0.25
        self.scene.addAnchor(cameraAnchor)
    }

    private func generateModelEntity(withName name: String) -> ModelEntity {
        let occlusion = OcclusionMaterial()
        let newEntity = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.01), materials: [occlusion])
        newEntity.name = name
        return newEntity
    }
}
