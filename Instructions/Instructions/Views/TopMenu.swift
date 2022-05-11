import SwiftUI

struct TopMenu: View {
    @Binding var editingMode: Bool
    
    var body: some View {
            HStack {
                Spacer()
                EditButtonView(
                    isEnable: $editingMode,
                    imageNameTrue: "camera.metering.center.weighted",
                    imageNameFalse: "camera.metering.center.weighted.average"
                ) {
                    editingMode.toggle()
                }
            }
            .padding(.top, 50)
            .padding(.trailing, 20)
    }
}
