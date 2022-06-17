import SwiftUI

struct AddNewSceneView: View {
    @Binding var scene: ARScene

    @State private var showAlert = false

    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Create Scene")
                .font(.system(size: 30, weight: .semibold))
            CustomTextField(text: $scene.name, title: "Scene name")
            CustomTextField(text: $scene.anchorImageWidth, title: "Image Width")
            LibraryImage(uiImage: $scene.anchorImage)

            Button {
                guard !scene.name.isBlank,
                      !scene.anchorImageWidth.isBlank,
                      scene.anchorImage != UIImage() else {
                    showAlert.toggle()
                    return
                }
                action()

            } label: {
                Text("Save")
                    .fontWeight(.medium)
                    .foregroundColor(.black)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(Constants.myBlue)
            .cornerRadius(24)
            .alert(Constants.alertMessageEmptyTitle, isPresented: $showAlert) {
                Button("OK", role: .cancel) {
                    showAlert.toggle()
                }
            }
        }
        .padding()
    }
}


struct LibraryImage: View {
    @Binding var uiImage: UIImage?

    @State private var showAction: Bool = false
    @State private var showImagePicker: Bool = false

    var sheet: ActionSheet {
        ActionSheet(
            title: Text("Action"),
            message: Text("Quotemark"),
            buttons: [
                .default(Text("Change"), action: {
                    self.showAction = false
                    self.showImagePicker = true
                }),
                .cancel(Text("Close"), action: {
                    self.showAction = false
                }),
                .destructive(Text("Remove"), action: {
                    self.showAction = false
                    self.uiImage = nil
                })
            ])

    }


    var body: some View {
        VStack {
            if uiImage != nil {
                Image(uiImage: uiImage!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .contentShape(RoundedRectangle(cornerRadius: 10))
                    .clipped()
                    .onTapGesture {
                        self.showAction = true
                    }
            } else {
                Image(systemName: "photo")
                    .foregroundColor(.gray)
                    .font(.system(size: 40))
                    .frame(maxWidth: .infinity, minHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .contentShape(RoundedRectangle(cornerRadius: 10))
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.gray.opacity(0.5), lineWidth: 1)
                            .background(RoundedRectangle(cornerRadius: 10))
                    )
                    .onTapGesture {
                        self.showImagePicker = true
                    }
            }
        }
        .sheet(isPresented: $showImagePicker, onDismiss: {
            self.showImagePicker = false
        }, content: {
            ImagePicker(isShown: self.$showImagePicker, uiImage: self.$uiImage)
        })
        
        .actionSheet(isPresented: $showAction) {
            sheet
        }
    }
}
