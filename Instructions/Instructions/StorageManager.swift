import SwiftUI
import FirebaseStorage
import FirebaseFirestore

public class StorageManager: ObservableObject {
    let storage = Storage.storage()
    let database = Firestore.firestore()

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

    func getImage(url: URL) -> UIImage? {
        var uiImage: UIImage?
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data {
//                DispatchQueue.main.async {
                    uiImage = UIImage(data: data)
//                }
            }
        }.resume()
        return uiImage
    }

    func uploadEntityPosition(entityName: String, position: SIMD3<Float>){
        let docref = database.document("scenes/\(entityName)")
        docref.setData(["entityName" : entityName,
                        "x" : position.x,
                        "y" : position.y,
                        "z" : position.z])
     }

    func getEntitiesPositions( completion: @escaping([MarkerEntity]) -> Void) {
        var markerEnities: [MarkerEntity] = []
        self.database.collection("scenes").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion([])
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    guard let entityName = data["entityName"] as? String,
                          let x = data["x"] as? Float,
                          let y = data["y"] as? Float,
                          let z = data["z"] as? Float
                    else {
                        return
                    }
                    markerEnities.append(MarkerEntity(name: entityName, x: x, y: y, z: z))
                }
                completion(markerEnities)
            }
        }
    }
}
