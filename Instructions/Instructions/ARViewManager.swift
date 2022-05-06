//
//  CustomARView.swift
//  furniture
//
//  Created by Yulia Sorokopud on 30.04.2022.
//

import ARKit
import RealityKit
import SwiftUI

class ARViewManager: ARView {
    /// stores all child entities added to the scene
    public var rootEntity = Entity()
    private var imageAnchorToEntity: [ARAnchor: AnchorEntity] = [:]

    // temporary image anchor
    private let imageAnchor = AnchorEntity(.image(group: "AR Resources",
                                                  name: "qrImage"))

    internal required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)

        self.session.delegate = self
        self.scene.anchors.append(imageAnchor)
    }

    @MainActor required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ARSessionDelegate

extension ARViewManager: ARSessionDelegate {
    /// responds each time new anchor is added to the session
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        anchors.compactMap { $0 as? ARImageAnchor }.forEach { imageAnchor in
            let anchorEntity = AnchorEntity()
            [rootEntity].forEach { anchorEntity.addChild($0)}
            self.scene.addAnchor(anchorEntity)
            self.imageAnchorToEntity[imageAnchor] = anchorEntity
        }
    }
    /// updates anchor with image transform
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        anchors.compactMap { $0 as? ARImageAnchor }.forEach {
            let anchorEntity = imageAnchorToEntity[$0]
            anchorEntity?.transform.matrix = $0.transform
        }
    }
}

//MARK: - Object adding
extension ARViewManager {
    /// add new model entity to the scene (adding sphere in front of camera)
    func addNewEntity() {
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
