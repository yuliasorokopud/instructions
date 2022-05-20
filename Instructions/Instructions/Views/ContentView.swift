import ARKit
import HalfASheet
import RealityKit
import SwiftUI

struct ContentView: View {
    @StateObject var scenesViewModel = ScenesViewModel()

    @State var createSceneModelPresented: Bool = false
    @State var currentScene: ARScene = ARScene(name: "",
                                               anchorImageWidth: "",
                                               instructions: [])

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(scenesViewModel.scenes) { scene in
                        NavigationLink(destination: ARSceneView(arViewModel: ARViewModel(scene: scene))) {
                            Text("\(scene.name)")
                        }
                    }
                }
                .hidden(scenesViewModel.scenes.isEmpty)
                Text("Create your first scene")
                    .hidden(!scenesViewModel.scenes.isEmpty)

            }
            .navigationBarTitle("Scenes")
            . toolbar {
                ToolbarItemGroup (placement: .navigationBarTrailing) {
                    Button(action: {
                        createSceneModelPresented = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }

        }

        .sheet(isPresented: $createSceneModelPresented,
               onDismiss: {
            createSceneModelPresented = false
        }) {
            AddNewSceneView(scene: $currentScene) {
                createSceneModelPresented.toggle()
                DispatchQueue.main.async {
                    scenesViewModel.uploadScene(scene: currentScene)
                    scenesViewModel.scenes.append(currentScene)
                    refreshStates()
                }
            }
        }
    }

    func refreshStates() {
        currentScene  = ARScene(name: "", anchorImageWidth: "", instructions: [])
    }
}
