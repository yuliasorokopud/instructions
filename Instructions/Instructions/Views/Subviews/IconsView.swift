import SwiftUI

struct IconsRow: View {
    @Binding var selectedIconName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            DescribingText(title: Constants.icons)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(Constants.iconsArray, id: \.self) {
                        IconImage(isSelected: selectedIconName == $0 ? true : false,
                                  iconName: $0,
                                  selectedIconName: $selectedIconName)
                    }
                }
            }
        }
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
