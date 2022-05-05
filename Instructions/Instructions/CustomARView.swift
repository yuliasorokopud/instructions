//
//  CustomARView.swift
//  furniture
//
//  Created by Yulia Sorokopud on 30.04.2022.
//

import ARKit
import RealityKit
import SwiftUI

class CustomARView: ARView {

    public var sceneRoot = Entity()
    let imageAnchor = AnchorEntity(.image(group: "AR Resources",
                                     name: "qrImage"))
    var imageAnchorToEntity: [ARAnchor: AnchorEntity] = [:]

    internal required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)

        configure()
        self.scene.anchors.append(imageAnchor)
        enableMarkerAdding()
    }

    @MainActor required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
//        self.scene.anchors.append(<#T##entity: Scene.AnchorCollection.Element##Scene.AnchorCollection.Element#>)
    }
}



//MARK: - Object adding
extension CustomARView {
    func enableMarkerAdding() {
        let longPressGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(longPressGesture)
    }

    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        let newEntity = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.01))
        newEntity.name = "new entity"
        let cameraAnchor = AnchorEntity(.camera)
        cameraAnchor.name = "CameraAnchor"
        cameraAnchor.addChild(newEntity)
        newEntity.position.z = -0.25
        self.scene.addAnchor(cameraAnchor)
        imageAnchor.addChild(newEntity, preservingWorldTransform: true)
        print("\(newEntity)")
        print("Adding child")
    }
}
