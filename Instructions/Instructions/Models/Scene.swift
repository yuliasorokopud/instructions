import SwiftUI

struct ARScene {
    var anchorImage: UIImage
    var anchorImageWidth: Double
    var instructions: [Instruction]
    var sceneName: String
}

struct Instructionn: Identifiable {
    let id: UUID
    let title: String
    let description: String
}

struct MarkerEntity {
    let name: String
    let x: Float
    let y: Float
    let z: Float
}
