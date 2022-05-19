import SwiftUI

struct MarkerOverlayView: View {
    var position: CGPoint?
    var title: String
    var iconName: String?

    var body: some View {
        if let position = position {
            Image(systemName: iconName == nil ? "bell" : iconName!)
                .font(.system(size: 30))
                .clipShape(Circle())
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.4))
                        .frame(width: 50, height: 50)
                        .overlay(Circle().stroke(.blue, lineWidth: 4))
                )
                .position(position)
                .padding()
                .onTapGesture {
                    print("InstructionView tapped with number: \(title)")
                }
        }
    }
}
