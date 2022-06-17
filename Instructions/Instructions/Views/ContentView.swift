import ARKit
import HalfASheet
import RealityKit
import SwiftUI

struct ContentView: View {
    @StateObject var scenesViewModel = ScenesViewModel()

    @State private var createSceneModalPresented: Bool = false
    @State private var currentScene: ARScene = ARScene(name: "",
                                               anchorImageWidth: "",
                                               instructions: [])

    var body: some View {
        NavigationView {
            switch scenesViewModel.loadingState {
            case .finished:
                VStack {
                    List {
                        ForEach(scenesViewModel.scenes) { scene in
                            NavigationLink(destination: ARInstructionsSceneView(arViewModel: ARViewModel(scene: scene))) {
                                Text("\(scene.name)")
                            }
                        }
                    }
                    .hidden(scenesViewModel.scenes.isEmpty)
                    Text("Create your first scene")
                        .hidden(!scenesViewModel.scenes.isEmpty)
                        .frame(alignment: .top)

                }
                .navigationBarTitle("Scenes")
                . toolbar {
                    ToolbarItemGroup (placement: .navigationBarTrailing) {
                        Button(action: {
                            createSceneModalPresented = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            case .idle, .loadingStarted:
                LaunchView()
            }

        }

        .sheet(isPresented: $createSceneModalPresented,
               onDismiss: {
            createSceneModalPresented = false
        }) {
            AddNewSceneView(scene: $currentScene) {
                createSceneModalPresented.toggle()
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
