import ARKit
import RealityKit
import SwiftUI

struct ContentView: View {
    @ObservedObject var arViewModel = ARViewModel()
    var body: some View {
        ZStack {
            ARViewContainer(arView: arViewModel.arView).edgesIgnoringSafeArea(.all)
            VStack {
                TopMenu(editingMode: $arViewModel.editingMode)
                Spacer()
                if arViewModel.editingMode {
                    ButtonView(imageName: "cube.fill") {
                        arViewModel.addMarker()
                    }
                }
            }
            MarkerOverlayView(position: $arViewModel.imageAnchorScreenPosition)
        }
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
