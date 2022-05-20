import SwiftUI

struct AddInstructionSheetView: View {
    @Binding var instruction: Instruction
    @Binding var showSheet: Bool
    @Binding var isAdding: Bool

    @State var showAlert: Bool = false

    let action: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            CustomTextField(text: $instruction.title, title: ViewConstants.instructionName)
            CustomTextField(text: $instruction.description.toUnwrapped(defaultValue: ""), title: ViewConstants.instructionDescription)
            IconsRow(selectedIconName: $instruction.iconName.toUnwrapped(defaultValue: ""))

            Button {
                if !instruction.title.isBlank {
                    showSheet.toggle()
                    action()
                    isAdding = true
                } else {
                    showAlert.toggle()
                }
            } label: {
                Text(isAdding ? ViewConstants.addMarkerToSceneButton : ViewConstants.editInstruction)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(isAdding ? ViewConstants.myGreen : ViewConstants.myBlue)
            .cornerRadius(24)
            .alert(ViewConstants.alertMessageEmptyTitle, isPresented: $showAlert) {
                Button("OK", role: .cancel) {
                    showAlert.toggle()
                }
            }
        }
        .padding()
    }
}

struct CustomTextField: View {
    @Binding var text: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            DescribingText(title: title)
                .font(.system(size: 15, weight: .heavy))
            TextField(title, text: $text)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(.black.opacity(0.2), lineWidth: 0.5)
                )
        }
    }
}

struct IconsRow: View {
    @Binding var selectedIconName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            DescribingText(title: ViewConstants.icons)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(ViewConstants.iconsArray, id: \.self) {
                        IconImage(isSelected: selectedIconName == $0 ? true : false,
                                  iconName: $0,
                                  selectedIconName: $selectedIconName)
                    }
                }
            }
        }
    }
}

struct DescribingText: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size: 15, weight: .heavy))
    }
}

struct IconImage: View {
    var isSelected: Bool
    let iconName: String
    @Binding var selectedIconName: String

    var body: some View {
        ZStack {
            isSelected ? Color.black.opacity(0.15) : Color.gray.opacity(0.15)
            Image(systemName: iconName)
                .font(.system(size: 25))
                .foregroundColor(.black)
                .buttonStyle(PlainButtonStyle())
        }
        .frame(width: 50, height: 50)
        .cornerRadius(10)
        .onTapGesture {
            selectedIconName = iconName
        }
    }
}

struct ViewConstants {
    // creation
    static let alertMessageEmptyTitle = "Title should not be empty"
    static let addInstruction = "Add instruction"
    static let editInstruction = "Edit instruction"

    static let instructionName = "Instruction name"
    static let instructionDescription = "Description"
    static let icons = "Icons"
    static let iconsArray = ["sun.min", "pencil", "trash", "folder", "bookmark", "link", "bell", "gearshape", "paintbrush", "briefcase", "fork.knife", "lightbulb", "airplane", "flame", "heart"]

    // adding to scene
    static let addMarkerToSceneButton = "Add marker to scene"
    static let placeMarker = "Place"

    // colors
    static let myGreen = Color("myGreen")
    static let myBlue = Color("myBlue")
}
