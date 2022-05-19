import SwiftUI

struct ARScene {
    let id = UUID().uuidString
    let sceneName: String
    let anchorImage: UIImage
    let anchorImageWidth: Double
    let instructions: [Instruction]
}

struct MarkerEntity {
    let instructionId: String
    let name: String
    let x: Float
    let y: Float
    let z: Float
}
