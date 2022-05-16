import ARKit
import HalfASheet
import RealityKit
import SwiftUI

struct ContentView: View {
    @ObservedObject var arViewModel = ARViewModel()

    @State var title: String = ""
    @State var description: String = ""
    @State var selectedIconName: String = ""
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State var showSheet = false

    var body: some View {
        ZStack {
            Color.white.opacity(0.25)
            ARViewContainer(arView: arViewModel.arView).edgesIgnoringSafeArea(.all)
            VStack {
                TopMenu(editingMode: $arViewModel.editingMode,
                        showSheet: $showSheet,
                        trashAction: {
                    arViewModel.clearScene()
                })
                .hidden(arViewModel.editingMode)

                Spacer()

                Button {
                    arViewModel.addMarker(for: Instruction(title: title,
                                                           description: description,
                                                           iconName: selectedIconName))
                    refreshStates()
                } label: {
                    Text("Place")
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                }
                .frame(width: 150, height: 34)
                .padding()
                .background(Color("myBlue"))
                .cornerRadius(15)
                .hidden(!arViewModel.editingMode)
            }
            VStack {
                Image(uiImage: arViewModel.image)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .hidden(!arViewModel.editingMode)
            }

            ForEach(arViewModel.instructions) {
                MarkerOverlayView(instruction: $0)
            }

            HalfASheet(isPresented: $showSheet, title: "Add Instruction") {
                AddInstructionSheetView(title: $title,
                                        description: $description,
                                        showSheet: $showSheet,
                                        selectedIconName: $selectedIconName) {
                    arViewModel.editingMode.toggle()
                }
            }
            .height(.proportional(0.50))
            .closeButtonColor(UIColor.white)
            .backgroundColor(.white)
            .contentInsets(EdgeInsets(top: 30, leading: 10, bottom: 30, trailing: 10))

//            HalfASheet(isPresented: $showSheet, title: "Edit Instruction") {
//                AddInstructionSheetView(title: $title,
//                                        description: $description,
//                                        showSheet: $showSheet,
//                                        selectedIconName: $selectedIconName) {
//                    arViewModel.editingMode.toggle()
//                }
//            }
//            .height(.proportional(0.50))
//            .closeButtonColor(UIColor.white)
//            .backgroundColor(.white)
//            .contentInsets(EdgeInsets(top: 30, leading: 10, bottom: 30, trailing: 10))
        }
    }

    func refreshStates() {
        title = ""
        description = ""
        selectedIconName = ""
    }
}

struct ARViewContainer: UIViewRepresentable {
    let arView: ARView

    func makeUIView(context: Context) -> ARView {
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


extension View {
    func hidden(_ isHidden: Bool) -> some View{
        opacity(isHidden ? 0 : 1)
    }
}

extension String {
    func emptyToNil() -> String? {
        self.isBlank ? nil: self
    }

    var isBlank: Bool {
        trimmingCharacters(in: .whitespaces).isEmpty ? true : false
    }
}
