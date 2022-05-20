import ARKit
import HalfASheet
import RealityKit
import SwiftUI

enum InstructionState {
    case none

    case isAdding
    case isEditing
}

struct ARInstructionsSceneView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @StateObject var arViewModel: ARViewModel

    @State private var instruction  = Instruction(title: "", description: "", iconName: "")
    @State private var instructionState: InstructionState = .none

    @State private var showSheet = false
    @State private var showAlert = false

    var body: some View {

        ZStack {
            ARViewContainer(arView: arViewModel.arView).edgesIgnoringSafeArea(.all)
            TopMenu(
                showSheet: $showSheet,
                title: arViewModel.scene.name,
                backAction: {
                    presentationMode.wrappedValue.dismiss()
                    arViewModel.quitArSession()
                },
                trashAction: {
                    arViewModel.clearScene()
                },
                addAction: {
                    if arViewModel.imageAnchorViewPosition != nil {
                        refreshStates()
                        showSheet.toggle()
                    } else {
                        showAlert.toggle()
                    }
                }
            )
            .hidden(arViewModel.editingMode)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 20)
            .alert(Constants.alertImageNotRecognized, isPresented: $showAlert) {
                Button("OK", role: .cancel) {
                    showAlert.toggle()
                }
            }

            Image(uiImage: UIImage(systemName: "circle")!)
                .resizable()
                .frame(width: 50, height: 50)
                .hidden(!arViewModel.editingMode)


            VStack {
                Button {
                    arViewModel.addMarker( for: Instruction( title: instruction.title,
                                                             description: instruction.description,
                                                             iconName: instruction.iconName))
                    refreshStates()
                } label: {
                    Text(Constants.placeMarker)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                }
                .frame(width: 150, height: 34)
                .padding()
                .background(Constants.myBlue)
                .cornerRadius(15)
                .hidden(!arViewModel.editingMode)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)

            ForEach(arViewModel.instructions) { item in
                EntityOverlayView(instruction: item) {
                    instruction = item
                    instructionState = .isEditing
                    showSheet.toggle()
                }
            }

            ImageRectangleStrokeView(image: arViewModel.scene.anchorImage!)
                .frame(alignment: .bottom)
                .hidden(arViewModel.imageAnchorViewPosition != nil)
                .transition(.scale)


            HalfASheet(isPresented: $showSheet, title: Constants.addInstruction) {
                AddInstructionSheetView(instruction: $instruction, showSheet: $showSheet, instructionState: $instructionState) {
                    switch instructionState {
                    case .none, .isAdding:
                        arViewModel.editingMode.toggle()
                    case .isEditing:
                        arViewModel.updateInstruction(instruction)
                    }
                } deleteAction: {
                    arViewModel.deleteInstruction(instruction)
                    refreshStates()
                }
            }
            .height(.proportional(0.50))
            .closeButtonColor(UIColor.white)
            .backgroundColor(.white)
            .contentInsets(EdgeInsets(top: 30, leading: 10, bottom: 30, trailing: 10))
            .navigationBarHidden(true)
        }
    }

    func refreshStates() {
        instruction.title = ""
        instruction.description = ""
        instruction.iconName = ""
        instructionState = .none
    }
}

struct ARViewContainer: UIViewRepresentable {
    let arView: ARView

    func makeUIView(context: Context) -> ARView {
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
