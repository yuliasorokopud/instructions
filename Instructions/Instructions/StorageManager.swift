import SwiftUI
import FirebaseStorage
import FirebaseFirestore

public class StorageManager: ObservableObject {
    private let storage = Storage.storage()
    private let database = Firestore.firestore()

    // MARK: - uploading data
    public func uploadImage(image: UIImage, sceneNamePrefix: String, completion: @escaping(URL) -> Void) {
        let storageRef = Storage.storage().reference().child("images/\(sceneNamePrefix)referenceImage.png")
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

    public func uploadEntityPosition(entityName: String, position: SIMD3<Float>, instId: String) {
        let docref = database.document("entities/\(entityName)")
        docref.setData(["instuctionId": instId,
                        "entityName" : entityName,
                        "x" : position.x,
                        "y" : position.y,
                        "z" : position.z])
    }

    func uploadNewInstruction(instruction: Instruction) {
        let docref = database.document("instructions/\(instruction.id)")

        docref.setData(["id" : instruction.id,
                        "title" : instruction.title,
                        "description" : instruction.description ?? "",
                        "iconName" : instruction.iconName ?? ""])
    }

    // MARK: - retrieving data
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

    func retrieveInstructions(completion: @escaping([Instruction]) -> Void) {
        var instructions: [Instruction] = []
        self.database.collection("instructions").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion([])
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    guard let id = data["id"] as? String,
                          let title = data["title"] as? String,
                          let description = data["description"] as? String
                    else { return }
                    let iconName = data["iconName"] as? String

                    instructions.append(Instruction(id: id, title: title, description: description, iconName: iconName))
                }
                completion(instructions)
            }
        }
    }

    // TODO: fix
    public func getImage(url: URL) -> UIImage? {
        var uiImage: UIImage?
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data {
                DispatchQueue.main.async {
                    uiImage = UIImage(data: data)
                }
            }
        }.resume()
        return uiImage
    }


    // MARK: - deleting data
    public func clearScene(){
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
}
