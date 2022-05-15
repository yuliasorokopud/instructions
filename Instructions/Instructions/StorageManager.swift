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

//    func getText() {
//        let docref = database.document("scenes/example")
//        docref.getDocument { snapshot, error in
//            guard let data = snapshot?.data(),
//                    error == nil,
//                  let dataString = data["instructionsCount"] as? String
//            else {
//                return
//            }
//
//            self.text = dataString
//        }
//    }
//
//    func uploadText(text: String = "striiing"){
//        let docref = database.document("scenes/example")
//        docref.setData(["instructionsCount" : "\(instructions.count)"])
//        getText()
//     }
}
