import SwiftUI

class ScenesViewModel: ObservableObject {
    @Published var scenes: [ARScene] = []
    @Published var loadingState: LoadingState = .idle

    private var storageManager = StorageManager()

    enum LoadingState {
        case idle
        case loadingStarted
        case finished
    }
    
    init() {
        populateScenes()
    }
    
    func populateScenes() {
        loadingState = .loadingStarted
        storageManager.retrieveScenes { scenes in
            self.getImages(scenes: scenes)
            DispatchQueue.main.async {
                self.scenes = scenes
            }

        }
    }

    func getImages(scenes: [ARScene]) {
        scenes.forEach { scene in
            self.storageManager.retrieveImage(for: scene) { [weak self] image in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    scene.anchorImage = image
                    self.loadingState = .finished
                }
            }
        }
    }

    func uploadScene(scene: ARScene) {
        storageManager.uploadNewScene(scene: scene)
    }
}
