import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

public class FirebaseManager: NSObject, ObservableObject {
    public static let shared = FirebaseManager()
    
    public let auth: Auth
    public let storage: Storage
    public let firestore: Firestore
    
    @Published public var currentUser: ChatUser?
    
    override private init() {
        if FirebaseApp.app() == nil {
            if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
               let options = FirebaseOptions(contentsOfFile: path) {
                FirebaseApp.configure(options: options)
            #if SWIFT_PACKAGE
            } else if let path = Bundle.module.path(forResource: "GoogleService-Info", ofType: "plist"),
                      let options = FirebaseOptions(contentsOfFile: path) {
                FirebaseApp.configure(options: options)
            #endif
            } else {
                FirebaseApp.configure()
            }
        }
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
}
