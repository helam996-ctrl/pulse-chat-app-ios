import Foundation
import FirebaseFirestore
#if canImport(FirebaseFirestoreSwift)
import FirebaseFirestoreSwift
#endif

public struct ChatMessage: Identifiable, Codable {
    @DocumentID public var id: String?
    public let fromId: String
    public let toId: String
    public let text: String
    public let timestamp: Date
    
    public var isFromCurrentUser: Bool {
        return fromId == FirebaseManager.shared.auth.currentUser?.uid
    }
    
    public var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    public init(id: String? = nil, fromId: String, toId: String, text: String, timestamp: Date = Date()) {
        self.id = id
        self.fromId = fromId
        self.toId = toId
        self.text = text
        self.timestamp = timestamp
    }
    
    public init(documentId: String, data: [String: Any]) {
        self.id = documentId
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
        
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
            FirebaseConstants.fromId: fromId,
            FirebaseConstants.toId: toId,
            FirebaseConstants.text: text,
            FirebaseConstants.timestamp: Timestamp(date: timestamp)
        ]
    }
}
