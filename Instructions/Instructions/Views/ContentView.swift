import ARKit
import RealityKit
import SwiftUI

struct ContentView: View {
    @ObservedObject var arViewModel = ARViewModel()

    @State var title: String = ""
    @State var description: String = ""

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

            ForEach(arViewModel.instructions) {
                MarkerOverlayView(position: $0.markerViewPosition,
                                  title: $0.title)
            }

            InstructionCreationView(title: $title,
                                    description: $description,
                                    action: { arViewModel.editingMode.toggle() }
            )
            .hidden(arViewModel.editingMode)
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


extension View {
    func hidden(_ isHidden: Bool) -> some View{
        opacity(isHidden ? 0 : 1)
    }
}
