import Foundation

public struct ChatUser: Identifiable, Codable, Hashable {
    public var id: String { uid }
    public let uid: String
    public let email: String
    public let profileImageUrl: String
    
    public var username: String {
        email.components(separatedBy: "@").first ?? email
    }
    
    public init(uid: String, email: String, profileImageUrl: String) {
        self.uid = uid
        self.email = email
        self.profileImageUrl = profileImageUrl
    }
    
    public init(data: [String: Any]) {
        self.uid = data[FirebaseConstants.uid] as? String ?? ""
        self.email = data[FirebaseConstants.email] as? String ?? ""
        self.profileImageUrl = data[FirebaseConstants.profileImageUrl] as? String ?? ""
    }
    
    public var dictionary: [String: Any] {
        return [
            FirebaseConstants.uid: uid,
            FirebaseConstants.email: email,
            FirebaseConstants.profileImageUrl: profileImageUrl
        ]
    }
}
