import Firebase
import SwiftUI

@main
struct InstructionsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    init() {
        FirebaseApp.configure()
        Auth.auth().signInAnonymously { authResult, error in
            guard let user = authResult?.user  else {
                print("couldn't auth")
                return
            }
            let uid = user.uid
            print("auth for uid: \(uid)")

        }
    }
}

