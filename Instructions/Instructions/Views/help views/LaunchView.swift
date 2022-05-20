import SwiftUI

struct LaunchView: View {
    var body: some View {
        ZStack {
            BlurView(style: .light).opacity(0.8)
            VStack(spacing: 150) {
                Image("arinstructions1")
                    .resizable()
                    .frame(width: 150, height: 129)
                ProgressView()
            }
            .padding()
        }
    }
}
