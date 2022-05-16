import SwiftUI

struct AddInstructionSheetView: View {
    @Binding var title: String
    @Binding var description: String
    @Binding var showSheet: Bool
    @Binding var selectedIconName: String
    @State var showAlert: Bool = false
    let action: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            CustomTextField(text: $title, title: "Instruction name")
            CustomTextField(text: $description, title: "Description")
            IconsRow(selectedIconName: $selectedIconName)

            Button {
                if !title.isBlank {
                    showSheet.toggle()
                    action()
                } else {
                    showAlert.toggle()
                }
            } label: {
                Text("Add marker to scene")
                    .fontWeight(.medium)
                    .foregroundColor(.black)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(Color("myGreen"))
            .cornerRadius(24)
            .alert("Title should not be empty", isPresented: $showAlert) {
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
    let icons = ["sun.min", "pencil", "trash", "folder", "bookmark", "link", "bell", "gearshape", "paintbrush", "briefcase", "fork.knife", "lightbulb", "airplane", "flame", "heart"]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            DescribingText(title: "Icons")
            ScrollView(.horizontal, showsIndicators: false){
                HStack {
                    ForEach(icons, id: \.self) {
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
