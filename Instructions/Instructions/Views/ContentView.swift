import ARKit
import RealityKit
import SwiftUI

struct ContentView: View {
    @ObservedObject var arViewModel = ARViewModel()

    @State var title: String = ""
    @State var description: String = ""
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State var showSheet = false

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

            Text(arViewModel.text)
            VStack {
                Image(uiImage: arViewModel.image)
                    .resizable()
                    .frame(width: 50, height: 50)

                ButtonView(imageName: "circle") {
                    showSheet.toggle()
                }
                .sheet(isPresented: $showSheet) {
                    ImagePicker(image: $arViewModel.image, sourceType: $sourceType)
                        .onDisappear {
                            arViewModel.arView.addReferenceImage(for: arViewModel.image, name: "name", width: 8/100)
                        }
                }
            }

            ForEach(arViewModel.instructions) {
                MarkerOverlayView(position: $0.markerViewPosition,
                                  title: $0.title)
            }
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
