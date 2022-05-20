import FirebaseFirestore
import FirebaseStorage
import RealityKit
import SwiftUI

public class StorageManager {
    private let storage = Storage.storage()
    private let database = Firestore.firestore()

    // MARK: - uploading data
    /// uploading reference image to Firebase
    public func uploadImage(image: UIImage, sceneId: String, completion: @escaping(URL) -> Void) {
        let storageRef = Storage.storage().reference().child("images/\(sceneId).png")
        if let uploadData = image.pngData() {
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"
            storageRef.putData(uploadData, metadata: metadata) { (metadata, error) in
                if let error = error {
                    print ("DEBUG: fail to upload image \(error.localizedDescription)")
                    return
                }

                storageRef.downloadURL{ (url, error) in
                    guard let imageUrl = url else {return}
                    completion(imageUrl)
                }

            }
        }
    }

    /// uploading entity position to firebase, with instruction id FK
    public func uploadEntity(_ entity: Entity, instId: String) {
        let docref = database.document("entities/\(instId)")
        docref.setData(["instuctionId": instId,
                        "entityName" : entity.name,
                        "x" : entity.position.x,
                        "y" : entity.position.y,
                        "z" : entity.position.z])
    }

    /// uploading instruction to firebase, with scene id FK
    func uploadNewInstruction(instruction: Instruction, toSceneWithId: String) {
        let docref = database.document("instructions/\(instruction.id)")

        docref.setData(["sceneId": toSceneWithId,
                        "id" : instruction.id,
                        "title" : instruction.title,
                        "description" : instruction.description ?? "",
                        "iconName" : instruction.iconName ?? ""])
    }

    /// uploading scene  to firebase. firstly load image then scene
    func uploadNewScene(scene: ARScene) {
        guard let image = scene.anchorImage else { return }
        uploadImage(image: image, sceneId: scene.id) { [weak self] url in
            scene.anchorImageUrl = url.absoluteString
            self?.uploadScene(scene: scene)
        }
    }

    private func uploadScene(scene: ARScene) {
        guard let imageUrl = scene.anchorImageUrl else { return }
        let docref = database.document("scenes/\(scene.id)")

        docref.setData(["id" : scene.id,
                        "name" : scene.name,
                        "anchorImageWidth" : scene.anchorImageWidth,
                        "sceneImageUrl" : imageUrl])
    }

    // MARK: - retrieving data
    /// fetching all entities
    func retrieveEntitiesPositions(completion: @escaping([MarkerEntity]) -> Void) {
        var markerEnities: [MarkerEntity] = []
        self.database.collection("entities").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion([])
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    guard let instId = data["instuctionId"] as? String,
                          let entityName = data["entityName"] as? String,
                          let x = data["x"] as? Float,
                          let y = data["y"] as? Float,
                          let z = data["z"] as? Float
                    else {
                        return
                    }
                    markerEnities.append(
                        MarkerEntity(
                            instructionId: instId,
                            name: entityName,
                            x: x, y: y, z: z
                        )
                    )
                }
                completion(markerEnities)
            }
        }
    }

    /// fetching all instructions that belong to the scene
    func retrieveInstructions(for scene: ARScene, completion: @escaping([Instruction]) -> Void) {
        var instructions: [Instruction] = []
        self.database.collection("instructions").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion([])
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    guard let sceneId = data["sceneId"] as? String,
                          let id = data["id"] as? String,
                          let title = data["title"] as? String,
                          let description = data["description"] as? String,
                          sceneId == scene.id
                    else {
                        continue
                    }
                    let iconName = data["iconName"] as? String

                    instructions.append(Instruction(id: id, title: title, description: description, iconName: iconName))
                }
                completion(instructions)
            }
        }
    }

    /// getting reference image for the scene
    func retrieveImage(for scene: ARScene, completion: @escaping(UIImage) -> Void) {
        let storageRef = Storage.storage().reference(withPath: "images/\(scene.id).png")
        storageRef.downloadURL { (url, error) in
            guard let url = url, error == nil else {
                return
            }
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        completion(image)
                    }
                }
            }
        }
    }

    /// fetching all created scenes
    func retrieveScenes(completion: @escaping([ARScene]) -> Void) {
        var scenes: [ARScene] = []
        self.database.collection("scenes").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion([])
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    guard let id = data["id"] as? String,
                          let name = data["name"] as? String,
                          let anchorImageWidth = data["anchorImageWidth"] as? String,
                          let urlString = data["sceneImageUrl"] as? String
                    else {
                        return
                    }
                    scenes.append(
                        ARScene(id: id,
                                name: name,
                                anchorImageWidth: anchorImageWidth,
                                anchorImageUrl: urlString,
                                instructions: [])
                    )
                }
                completion(scenes)
            }
        }
    }

    // MARK: - deleting data
    public func clearAllScenes() {
        deleteAllDocumentsInFirebaseCollectionNamed("entities")
        deleteAllDocumentsInFirebaseCollectionNamed("instructions")
    }

    private func deleteAllDocumentsInFirebaseCollectionNamed(_ collectionName: String) {
        database.collection(collectionName).getDocuments() { (querySnapshot, err) in
          if let err = err {
            print("Error getting documents: \(err)")
          } else {
            for document in querySnapshot!.documents {
              document.reference.delete()
            }
          }
        }
    }

    func deleteInstruction(_ instruction: Instruction) {
        let ref = database.collection("instructions")
        let query : Query = ref.whereField("id", isEqualTo: instruction.id)
        query.getDocuments(completion: { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                for document in snapshot!.documents {
                    self.database.collection("instructions").document(document.documentID).delete()
                }
            }})

        deleteEntityForInstructionWithId(instruction.id)
    }

    func deleteEntityForInstructionWithId(_ instructionId: String) {
        let ref = database.collection("entities")
        let query : Query = ref.whereField("instuctionId", isEqualTo: instructionId)
        query.getDocuments(completion: { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                for document in snapshot!.documents {
                    self.database.collection("entities").document(document.documentID).delete()
                }
            }})
    }

    func deleteAllInstructionsOnTheScene(_ scene: ARScene) {
        let ref = database.collection("instructions")
        let query : Query = ref.whereField("sceneId", isEqualTo: scene.id)
        query.getDocuments(completion: { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                for document in snapshot!.documents {
                    let data = document.data()
                    if let id = data["id"] as? String {
                        self.deleteEntityForInstructionWithId(id)
                    }
                    self.database.collection("instructions").document(document.documentID).delete()
                }
            }})
    }
}
