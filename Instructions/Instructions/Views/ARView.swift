import ARKit
import HalfASheet
import RealityKit
import SwiftUI


struct ARSceneView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @StateObject var arViewModel = ARViewModel()

    @State var instruction  = Instruction(title: "", description: "", iconName: "")
    @State var showSheet = false
    @State var isAdding = true

    //    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {

        ZStack {
            ARViewContainer(arView: arViewModel.arView).edgesIgnoringSafeArea(.all)
            TopMenu(showSheet: $showSheet,
                    backAction: { presentationMode.wrappedValue.dismiss() },
                    trashAction: { arViewModel.clearScene() }
            )
            .hidden(arViewModel.editingMode)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 20)


            Image(uiImage: UIImage(systemName: "circle")!)
                .resizable()
                .frame(width: 50, height: 50)
                .hidden(!arViewModel.editingMode)


            VStack {
                Button {
                    arViewModel.addMarker(
                        for: Instruction(
                            title: instruction.title,
                            description: instruction.description,
                            iconName: instruction.iconName
                        )
                    )
                    refreshStates()
                } label: {
                    Text(ViewConstants.placeMarker)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                }
                .frame(width: 150, height: 34)
                .padding()
                .background(ViewConstants.myBlue)
                .cornerRadius(15)
                .hidden(!arViewModel.editingMode)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)

            ForEach(arViewModel.instructions) {
                MarkerOverlayView(position: $0.markerViewPosition,
                                  title: $0.title,
                                  iconName: $0.iconName)
            }

            HalfASheet(isPresented: $showSheet, title: ViewConstants.addInstruction) {
                AddInstructionSheetView(instruction: $instruction, showSheet: $showSheet, isAdding: $isAdding) {
                    if isAdding {
                        arViewModel.editingMode.toggle()
                    }
                    else {
                        //arViewModel.updateInstruction
                        print("updating instruction")
                    }
                }
            }
            .height(.proportional(0.50))
            .closeButtonColor(UIColor.white)
            .backgroundColor(.white)
            .contentInsets(EdgeInsets(top: 30, leading: 10, bottom: 30, trailing: 10))

            //            HalfASheet(isPresented: $showSheet, title: Constant.editInstruction) {
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
        .navigationBarHidden(true)

//        }
    }

    func refreshStates() {
        instruction.title = ""
        instruction.description = ""
        instruction.iconName = ""
    }
}

struct ARViewContainer: UIViewRepresentable {
    let arView: ARView

    func makeUIView(context: Context) -> ARView {
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}


struct NavigationBar: View {
    var body: some View {
        ZStack {
            Color.clear.background(.ultraThinMaterial)
                .blur(radius: 10)
            Text ( "Featured")
                .font(.largeTitle.weight(.bold))
                .frame (maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
        }
        frame(height: 70)
            . frame (maxHeight: .infinity, alignment: .top)
    }
}
