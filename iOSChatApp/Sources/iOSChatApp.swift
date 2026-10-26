import SwiftUI
import FirebaseCore

@main
public struct iOSChatApp: App {
    
    public init() {
        // Initialize FirebaseManager singleton which triggers FirebaseApp.configure()
        _ = FirebaseManager.shared
    }
    
    public var body: some Scene {
        WindowGroup {
            MainMessagesView()
        }
    }
}
