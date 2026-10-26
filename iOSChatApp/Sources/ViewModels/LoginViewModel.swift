import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@MainActor
public class LoginViewModel: ObservableObject {
    @Published public var isLoginMode = false
    @Published public var email = ""
    @Published public var password = ""
    @Published public var selectedImage: UIImage?
    @Published public var statusMessage = ""
    @Published public var isAuthenticating = false
    @Published public var didCompleteLoginProcess = false
    
    public init() {}
    
    public func handleAction() {
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self.statusMessage = "Please enter an email address."
            return
        }
        
        guard !password.isEmpty else {
            self.statusMessage = "Please enter a password."
            return
        }
        
        if isLoginMode {
            loginUser()
        } else {
            createNewAccount()
        }
    }
    
    private func loginUser() {
        isAuthenticating = true
        statusMessage = "Logging in..."
        
        Task {
            do {
                let result = try await FirebaseManager.shared.auth.signIn(
                    withEmail: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password
                )
                self.statusMessage = "Successfully logged in as: \(result.user.uid)"
                self.isAuthenticating = false
                self.didCompleteLoginProcess = true
            } catch {
                self.statusMessage = "Failed to log in: \(error.localizedDescription)"
                self.isAuthenticating = false
            }
        }
    }
    
    private func createNewAccount() {
        guard selectedImage != nil else {
            self.statusMessage = "Please select an avatar profile image."
            return
        }
        
        isAuthenticating = true
        statusMessage = "Creating account..."
        
        Task {
            do {
                let result = try await FirebaseManager.shared.auth.createUser(
                    withEmail: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password
                )
                let uid = result.user.uid
                self.statusMessage = "Account created. Uploading profile image..."
                
                let imageUrl = try await uploadProfileImage(uid: uid)
                self.statusMessage = "Storing user information..."
                
                try await storeUserInformation(uid: uid, profileImageUrl: imageUrl)
                self.statusMessage = "Successfully registered user: \(uid)"
                self.isAuthenticating = false
                self.didCompleteLoginProcess = true
            } catch {
                self.statusMessage = "Failed to create account: \(error.localizedDescription)"
                self.isAuthenticating = false
            }
        }
    }
    
    private func uploadProfileImage(uid: String) async throws -> String {
        guard let image = selectedImage,
              let imageData = image.jpegData(compressionQuality: 0.5) else {
            throw NSError(
                domain: "LoginViewModel",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Failed to compress profile image."]
            )
        }
        
        let storageRef = FirebaseManager.shared.storage.reference(withPath: "\(FirebaseConstants.profileImagesFolder)/\(uid).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        let downloadUrl = try await storageRef.downloadURL()
        return downloadUrl.absoluteString
    }
    
    private func storeUserInformation(uid: String, profileImageUrl: String) async throws {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let userData: [String: Any] = [
            FirebaseConstants.uid: uid,
            FirebaseConstants.email: trimmedEmail,
            FirebaseConstants.profileImageUrl: profileImageUrl
        ]
        
        try await FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(uid)
            .setData(userData)
        
        let createdUser = ChatUser(uid: uid, email: trimmedEmail, profileImageUrl: profileImageUrl)
        FirebaseManager.shared.currentUser = createdUser
    }
}
