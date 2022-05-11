import RealityKit
import SwiftUI

class Instruction: Identifiable {
    let id = UUID().uuidString
    var title: String
    var description: String?
    
    var markerEntity: Entity?
    var entityPosition: SIMD3<Float>?
    var markerViewPosition: CGPoint?

    internal init(title: String) {
        self.title = title
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
