import Foundation

public struct FirebaseConstants {
    // Firestore Collection Names
    public static let users = "users"
    public static let messages = "messages"
    public static let recentMessages = "recent_messages"
    
    // Firestore Document Fields
    public static let uid = "uid"
    public static let fromId = "fromId"
    public static let toId = "toId"
    public static let text = "text"
    public static let timestamp = "timestamp"
    public static let email = "email"
    public static let profileImageUrl = "profileImageUrl"
    
    // Storage Folders
    public static let profileImagesFolder = "profile_images"
}
