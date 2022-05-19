import SwiftUI

struct TopMenu: View {
    @Binding var showSheet: Bool
    let backAction: () -> Void
    let trashAction: () -> Void

    var body: some View {
            HStack {
                ButtonView(imageName: "chevron.left") {
                    backAction()
                }

                Spacer()
                Text("scene name")
                ButtonView(imageName: "trash") {
                    trashAction()
                }
                ButtonView(imageName: "plus") {
                    showSheet.toggle()
                }
            }
            .padding(.top, 50)
            .padding(.horizontal, 20)
    }
}
