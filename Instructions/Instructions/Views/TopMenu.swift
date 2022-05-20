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
                Text("first instruction")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundColor(.black)
                Spacer()
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
