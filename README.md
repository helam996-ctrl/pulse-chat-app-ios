# iOSChatApp — SwiftUI Firebase Real-Time Chat

A production-ready, modular SwiftUI real-time chat application inspired by the **"Lets Build That App"** Firebase Chat architecture by Brian Voong, upgraded for **Swift 5.9+**, **iOS 16+**, and modern **MVVM with Combine & async/await**.

---

## 📁 Project Structure

```text
iOSChatApp/
├── Package.swift                             # Swift Package Manager manifest (Swift 5.9+, Firebase 10.20+)
├── project.yml                               # XcodeGen specification for native .xcodeproj generation
├── GoogleService-Info.plist                  # Firebase configuration placeholder
├── Sources/
│   ├── iOSChatApp.swift                      # App Entrypoint (@main & Firebase initialization)
│   ├── Utils/
│   │   ├── FirebaseConstants.swift          # Firestore collection & field keys
│   │   ├── FirebaseManager.swift            # Singleton manager for Auth, Firestore, Storage
│   │   └── ImagePicker.swift                # UIViewControllerRepresentable image picker
│   ├── Models/
│   │   ├── ChatUser.swift                   # User model (uid, email, profileImageUrl)
│   │   ├── ChatMessage.swift                # Real-time message model
│   │   └── RecentMessage.swift              # Conversation overview model with relative timestamps
│   ├── ViewModels/
│   │   ├── LoginViewModel.swift             # Auth registration, login, and avatar JPEG upload
│   │   ├── MainMessagesViewModel.swift      # Current user profile, recent messages, and signout
│   │   ├── CreateNewMessageViewModel.swift  # Registered users directory
│   │   └── ChatLogViewModel.swift           # Real-time message snapshot listener and bi-directional dispatch
│   └── Views/
│       ├── LoginView.swift                  # Segmented auth mode, avatar picker, form validation
│       ├── MainMessagesView.swift           # Top custom nav bar, recent messages list, floating action button
│       ├── CreateNewMessageView.swift       # Registered user selection sheet
│       └── ChatLogView.swift                # Chat bubbles, auto-scroll with ScrollViewReader, input bar
└── iOSChatAppUITests/
    └── iOSChatAppUITests.swift              # Automated UI test suite capturing CI screenshots
```

---

## 🗄️ Firestore Database Schema

The database follows the exact dual-write message and recent message snapshot structure:

1. **Users Collection:**
   ```text
   users/{uid}
       ├── uid: String
       ├── email: String
       └── profileImageUrl: String
   ```

2. **Real-time Messages Collection (Dual-Write for fast queries):**
   ```text
   messages/{fromId}/{toId}/{messageDocument}
   messages/{toId}/{fromId}/{messageDocument}
       ├── fromId: String
       ├── toId: String
       ├── text: String
       └── timestamp: Timestamp
   ```

3. **Recent Conversation Previews (Optimized for instant MainView loading):**
   ```text
   recent_messages/{currentUserId}/messages/{toId}
       ├── text: String
       ├── fromId: String
       ├── toId: String
       ├── profileImageUrl: String
       ├── email: String
       └── timestamp: Timestamp
   ```

---

## 🚀 Getting Started

### 1. Prerequisites
- macOS 14+ with Xcode 15+ (Swift 5.9+)
- Active Firebase Project with:
  - **Firebase Authentication** (Email & Password enabled)
  - **Cloud Firestore**
  - **Firebase Storage**

### 2. Configure Firebase
Replace [GoogleService-Info.plist](file:///d:/ios-chat-app-project-college/iOSChatApp/GoogleService-Info.plist) with your official downloaded file from the Firebase Console.

Recommended Firestore Security Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null;
    }
    match /messages/{fromId}/{toId}/{messageId} {
      allow read, write: if request.auth != null && (request.auth.uid == fromId || request.auth.uid == toId);
    }
    match /recent_messages/{userId}/messages/{toId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 3. Generate Xcode Project (Optional with XcodeGen)
If you have `xcodegen` installed via Homebrew (`brew install xcodegen`):
```bash
cd iOSChatApp
xcodegen generate
open iOSChatApp.xcodeproj
```
Or open [Package.swift](file:///d:/ios-chat-app-project-college/iOSChatApp/Package.swift) directly in Xcode.

---

## 🧪 CI / CD & Screenshot Extraction
The project includes a GitHub Actions workflow in [.github/workflows/ios-build.yml](file:///d:/ios-chat-app-project-college/.github/workflows/ios-build.yml) configured for `macos-14`:
- Resolves Firebase SDK dependencies.
- Builds the app with `xcodebuild`.
- Boots the iOS simulator and runs `iOSChatAppUITests`.
- Automatically captures full-resolution screenshots of `LoginView` and `MainMessagesView`.
- Uploads the screenshots as an artifact zip (`ios-ui-screenshots`).
