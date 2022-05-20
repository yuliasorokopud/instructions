import SwiftUI

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

struct DescribingText: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size: 15, weight: .heavy))
    }
}
