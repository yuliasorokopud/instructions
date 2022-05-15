import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {

    @Binding var image: UIImage
    @Environment(\.presentationMode)  var presentationMode
    @Binding var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator

        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}


final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var parent: ImagePicker

    init(_ parent: ImagePicker) {
        self.parent = parent
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            parent.image = image
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

}
