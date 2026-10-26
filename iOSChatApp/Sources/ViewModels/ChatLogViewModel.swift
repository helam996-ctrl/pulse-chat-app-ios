import Foundation
import FirebaseAuth
import FirebaseFirestore
#if canImport(FirebaseFirestoreSwift)
import FirebaseFirestoreSwift
#endif

@MainActor
public class ChatLogViewModel: ObservableObject {
    @Published public var chatText = ""
    @Published public var errorMessage = ""
    @Published public var chatMessages = [ChatMessage]()
    @Published public var count = 0
    
    public let chatUser: ChatUser?
    private var firestoreListener: ListenerRegistration?
    
    public init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        fetchMessages()
    }
    
    public func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid,
              let toId = chatUser?.uid else { return }
        
        firestoreListener?.remove()
        chatMessages.removeAll()
        
        firestoreListener = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .order(by: FirebaseConstants.timestamp, descending: false)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error.localizedDescription)"
                    return
                }
                
                guard let snapshot = querySnapshot else { return }
                
                snapshot.documentChanges.forEach { change in
                    if change.type == .added {
                        let data = change.document.data()
                        let message = ChatMessage(documentId: change.document.documentID, data: data)
                        self.chatMessages.append(message)
                    }
                }
                
                self.count += 1
            }
    }
    
    public func handleSend() {
        let trimmedText = chatText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid,
              let toId = chatUser?.uid else {
            self.errorMessage = "Missing sender or recipient identifier."
            return
        }
        
        let senderDocument = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .document()
        
        let recipientDocument = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(toId)
            .collection(fromId)
            .document(senderDocument.documentID)
        
        let messageData: [String: Any] = [
            FirebaseConstants.fromId: fromId,
            FirebaseConstants.toId: toId,
            FirebaseConstants.text: trimmedText,
            FirebaseConstants.timestamp: Timestamp()
        ]
        
        senderDocument.setData(messageData) { [weak self] error in
            if let error = error {
                self?.errorMessage = "Failed to save message to sender: \(error.localizedDescription)"
                return
            }
        }
        
        recipientDocument.setData(messageData) { [weak self] error in
            if let error = error {
                self?.errorMessage = "Failed to save message to recipient: \(error.localizedDescription)"
                return
            }
        }
        
        persistRecentMessage(text: trimmedText, fromId: fromId, toId: toId)
        
        self.chatText = ""
        self.count += 1
    }
    
    private func persistRecentMessage(text: String, fromId: String, toId: String) {
        guard let chatUser = self.chatUser else { return }
        let timestamp = Timestamp()
        
        // 1. Perspective of Sender (stored in current user's recent messages)
        let senderRecentData: [String: Any] = [
            FirebaseConstants.text: text,
            FirebaseConstants.fromId: fromId,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
            FirebaseConstants.email: chatUser.email,
            FirebaseConstants.timestamp: timestamp
        ]
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(fromId)
            .collection(FirebaseConstants.messages)
            .document(toId)
            .setData(senderRecentData) { [weak self] error in
                if let error = error {
                    self?.errorMessage = "Failed to persist sender recent message: \(error.localizedDescription)"
                }
            }
        
        // 2. Perspective of Recipient (stored in recipient's recent messages)
        let currentUser = FirebaseManager.shared.currentUser
        let senderEmail = currentUser?.email ?? FirebaseManager.shared.auth.currentUser?.email ?? ""
        let senderProfileImageUrl = currentUser?.profileImageUrl ?? ""
        
        let recipientRecentData: [String: Any] = [
            FirebaseConstants.text: text,
            FirebaseConstants.fromId: fromId,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: senderProfileImageUrl,
            FirebaseConstants.email: senderEmail,
            FirebaseConstants.timestamp: timestamp
        ]
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(toId)
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .setData(recipientRecentData) { [weak self] error in
                if let error = error {
                    self?.errorMessage = "Failed to persist recipient recent message: \(error.localizedDescription)"
                }
            }
    }
    
    deinit {
        firestoreListener?.remove()
    }
}
