import SwiftUI

struct AddInstructionSheetView: View {
    @Binding var instruction: Instruction
    @Binding var showSheet: Bool
    @Binding var instructionState: InstructionState

    @State private var showAlert: Bool = false

    let action: () -> Void
    let deleteAction: (() -> Void)

    var body: some View {
        VStack(spacing: 20) {
            CustomTextField(text: $instruction.title, title: Constants.instructionName)
            CustomTextField(text: $instruction.description.toUnwrapped(defaultValue: ""), title: Constants.instructionDescription)
            IconsRow(selectedIconName: $instruction.iconName.toUnwrapped(defaultValue: ""))

            HStack {
                Button {
                    if !instruction.title.isBlank {
                        action()
                        showSheet.toggle()
                        if instructionState == .isEditing {
                            instructionState = .none
                        } else {
                            instructionState = .isAdding
                        }
                    } else {
                        showAlert.toggle()
                    }
                } label: {
                    switch instructionState {
                    case .isAdding, .none:
                        Text(Constants.addMarkerToSceneButton)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                    case .isEditing:
                        HStack {
                            Text(Constants.editInstruction)
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                        }
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .background(Constants.myGreen)
                .cornerRadius(24)
                .alert(Constants.alertMessageEmptyTitle, isPresented: $showAlert) {
                    Button("OK", role: .cancel) {
                        showAlert.toggle()
                    }
                }
                if case .isEditing = instructionState {
                    Button {
                        deleteAction()
                        showSheet.toggle()
                    } label: {
                        Text("Delete")
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Constants.myRed)
                    .cornerRadius(24)
                    .foregroundColor(.white)
                }
            }
        }
        .padding()
    }
}
