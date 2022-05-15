import SwiftUI

struct ARScene {
    let id = UUID().uuidString
    let anchorImage: UIImage
    let anchorImageWidth: Double
    let instructions: [Instruction]
    let sceneName: String
}

struct MarkerEntity {
    let instructionId: String
    let name: String
    let x: Float
    let y: Float
    let z: Float
}
