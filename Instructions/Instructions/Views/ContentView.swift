import ARKit
import HalfASheet
import RealityKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ARSceneView()) {
                    Text("My scene")
                }
            }.navigationBarTitle("Scenes")
        }
    }
}


//            ProgressView()

//            AsyncImage(
//                url: URL(string: "https://XXX"),
//                content: { image in
//                    image.resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(maxWidth: 200, maxHeight: 100)
//                },
//                placeholder: {
//                    ProgressView()
//                }
//            )

//            AsyncImage(url: URL(string: "https://example.com/icon.png"))
//            { image in
//                image.resizable()
//            } placeholder: {
//                ProgressView()
//            }
//            .frame(width: 50, height: 50)

//
