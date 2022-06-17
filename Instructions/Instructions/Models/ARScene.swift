import SwiftUI

class ARScene: Identifiable {
    var id = UUID().uuidString
    var name: String
    var anchorImage: UIImage?
    var anchorImageWidth: String
    var anchorImageUrl: String?
    var instructions: [Instruction]

    init(id: String = UUID().uuidString,
         name: String, anchorImage: UIImage? = nil,
         anchorImageWidth: String,
         anchorImageUrl: String? = nil,
         instructions: [Instruction]) {
        self.id = id
        self.name = name
        self.anchorImage = anchorImage
        self.anchorImageWidth = anchorImageWidth
        self.anchorImageUrl = anchorImageUrl
        self.instructions = instructions
    }
}
