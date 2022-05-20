import SwiftUI

struct TopMenu: View {
    @Binding var showSheet: Bool
    var title: String
    
    let backAction: () -> Void
    let trashAction: () -> Void
    let addAction: () -> Void

    var body: some View {
            HStack {
                ButtonView(imageName: "chevron.left") {
                    backAction()
                }

                Spacer()
                Text(title)
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundColor(.black)
                Spacer()
                ButtonView(imageName: "trash") {
                    trashAction()
                }
                ButtonView(imageName: "plus") {
                    addAction()
                }
            }
            .padding(.top, 50)
            .padding(.horizontal, 20)
    }
}
