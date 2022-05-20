import SwiftUI

class ScenesViewModel: ObservableObject {
    @Published var scenes: [ARScene] = []

    var storageManager = StorageManager()

    init() {
        populateScenes()
    }
    
    func populateScenes() {
        storageManager.retrieveScenes { scenes in
            DispatchQueue.main.async {
                self.getImages(scenes: scenes)
                self.scenes = scenes
            }

        }
    }

    func getImages(scenes: [ARScene]) {
        scenes.forEach { [weak self] scene in
            guard let self = self else { return }
            self.storageManager.retrieveImage(for: scene) { image in
                scene.anchorImage = image
            }
        }
    }

    func uploadScene(scene: ARScene) {
        storageManager.uploadNewScene(scene: scene)
    }
}
