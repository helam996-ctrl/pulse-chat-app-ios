import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
public class CreateNewMessageViewModel: ObservableObject {
    @Published public var users = [ChatUser]()
    @Published public var errorMessage = ""
    @Published public var isLoading = false
    
    public init() {
        fetchAllUsers()
    }
    
    public func fetchAllUsers() {
        isLoading = true
        errorMessage = ""
        
        let currentUid = FirebaseManager.shared.auth.currentUser?.uid
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Failed to fetch users: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.errorMessage = "No users found."
                    return
                }
                
                self.users = documents.compactMap { document in
                    let user = ChatUser(data: document.data())
                    return user.uid != currentUid ? user : nil
                }
            }
    }
}
