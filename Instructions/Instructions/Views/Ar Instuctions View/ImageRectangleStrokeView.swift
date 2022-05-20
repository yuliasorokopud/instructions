import SwiftUI

struct ImageRectangleStrokeView: View {
    var image: UIImage
    var body : some View {
        VStack {
            Spacer()
            Image(uiImage: image)
                .resizable()
                .frame(width: 150, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .overlay(RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.yellow, lineWidth: 3)
                    .frame(width: 165, height: 165))

            Text("Face your device on the tagret \nimage to show instructions")
                .foregroundColor(.white)
                .padding(.horizontal, 60)

        }
    }
}
