import SwiftUI

struct TopMenu: View {
    @Binding var editingMode: Bool
    @Binding var showSheet: Bool

    let trashAction: () -> Void

    var body: some View {
            HStack {
                ButtonView(imageName: "chevron.left") {
                    ()
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
            .padding(.trailing, 20)
    }
}
