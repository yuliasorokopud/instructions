import RealityKit
import SwiftUI

class Instruction: Identifiable {
    var id = UUID().uuidString
    var title: String
    var description: String?
    var iconName: String?
    
    var markerEntity: Entity?
    var entityPosition: SIMD3<Float>?
    var markerViewPosition: CGPoint?

    internal init(id: String? = nil,
                  title: String,
                  description: String? = nil,
                  iconName: String? = nil) {
        if let id = id {
            self.id = id
        }
        self.title = title
        self.description = description?.emptyToNil()
        self.iconName = iconName?.emptyToNil()
    }

    func updateInstructionPosition() {
        self.entityPosition = self.markerEntity?.position
    }

    func setMarkerEntity(_ entity: Entity) {
        self.markerEntity = entity
        updateInstructionPosition()
    }

    func setMarkerScreenPosition(point: CGPoint) {
        self.markerViewPosition = point
    }
}
