import Foundation
import FirebaseFirestore
#if canImport(FirebaseFirestoreSwift)
import FirebaseFirestoreSwift
#endif

public struct RecentMessage: Identifiable, Codable {
    @DocumentID public var id: String?
    public let text: String
    public let fromId: String
    public let toId: String
    public let profileImageUrl: String
    public let email: String
    public let timestamp: Date
    
    public var username: String {
        email.components(separatedBy: "@").first ?? email
    }
    
    public var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    public init(id: String? = nil, text: String, fromId: String, toId: String, profileImageUrl: String, email: String, timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.fromId = fromId
        self.toId = toId
        self.profileImageUrl = profileImageUrl
        self.email = email
        self.timestamp = timestamp
    }
    
    public init(documentId: String, data: [String: Any]) {
        self.id = documentId
        self.text = data[FirebaseConstants.text] as? String ?? ""
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.profileImageUrl = data[FirebaseConstants.profileImageUrl] as? String ?? ""
        self.email = data[FirebaseConstants.email] as? String ?? ""
        
        if let firestoreTimestamp = data[FirebaseConstants.timestamp] as? Timestamp {
            self.timestamp = firestoreTimestamp.dateValue()
        } else if let date = data[FirebaseConstants.timestamp] as? Date {
            self.timestamp = date
        } else {
            self.timestamp = Date()
        }
    }
    
    public var dictionary: [String: Any] {
        return [
            FirebaseConstants.text: text,
            FirebaseConstants.fromId: fromId,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: profileImageUrl,
            FirebaseConstants.email: email,
            FirebaseConstants.timestamp: Timestamp(date: timestamp)
        ]
    }
}
