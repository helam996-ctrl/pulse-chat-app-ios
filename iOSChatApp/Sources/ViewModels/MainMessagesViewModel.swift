import Foundation
import FirebaseAuth
import FirebaseFirestore
#if canImport(FirebaseFirestoreSwift)
import FirebaseFirestoreSwift
#endif

@MainActor
public class MainMessagesViewModel: ObservableObject {
    @Published public var errorMessage = ""
    @Published public var chatUser: ChatUser?
    @Published public var isUserCurrentlyLoggedOut = false
    @Published public var recentMessages = [RecentMessage]()
    @Published public var shouldShowNewChatView = false
    @Published public var shouldNavigateToChatLogView = false
    
    private var firestoreListener: ListenerRegistration?
    
    public init() {
        self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        
        if !isUserCurrentlyLoggedOut {
            fetchCurrentUser()
            fetchRecentMessages()
        }
    }
    
    public func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find current authenticated user."
            return
        }
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(uid)
            .getDocument { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = "Failed to fetch current user: \(error.localizedDescription)"
                    return
                }
                
                guard let data = snapshot?.data() else {
                    self.errorMessage = "No user profile data found."
                    return
                }
                
                let user = ChatUser(data: data)
                self.chatUser = user
                FirebaseManager.shared.currentUser = user
            }
    }
    
    public func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        firestoreListener?.remove()
        self.recentMessages.removeAll()
        
        firestoreListener = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .order(by: FirebaseConstants.timestamp, descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = "Failed to listen to recent messages: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = querySnapshot?.documents else { return }
                
                self.recentMessages = documents.compactMap { document in
                    RecentMessage(documentId: document.documentID, data: document.data())
                }
            }
    }
    
    public func handleSignOut() {
        do {
            try FirebaseManager.shared.auth.signOut()
            self.isUserCurrentlyLoggedOut = true
            self.chatUser = nil
            self.recentMessages.removeAll()
            self.firestoreListener?.remove()
            self.firestoreListener = nil
            FirebaseManager.shared.currentUser = nil
        } catch {
            self.errorMessage = "Failed to sign out: \(error.localizedDescription)"
        }
    }
    
    deinit {
        firestoreListener?.remove()
    }
}
