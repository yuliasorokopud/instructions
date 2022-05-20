import SwiftUI

struct ButtonView: View {
    let imageName: String
    let buttonAction: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
            Button(action: {
                buttonAction()
            }) {
                Image(systemName: imageName)
                    .font(.system(size: 25))
                    .foregroundColor(.white)
                    .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(width: 50, height: 50)
        .cornerRadius(8)
    }
}
