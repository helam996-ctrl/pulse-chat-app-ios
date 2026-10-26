import SwiftUI

public struct MainMessagesView: View {
    @StateObject private var vm = MainMessagesViewModel()
    @State private var shouldShowLogOutOptions = false
    @State private var selectedChatUser: ChatUser?
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                customNavBar
                messagesView
                
                NavigationLink(
                    destination: ChatLogView(chatUser: selectedChatUser),
                    isActive: $vm.shouldNavigateToChatLogView
                ) {
                    EmptyView()
                }
            }
            .overlay(
                newMessageFloatingButton,
                alignment: .bottomTrailing
            )
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut) {
            LoginView(didCompleteLoginProcess: {
                vm.isUserCurrentlyLoggedOut = false
                vm.fetchCurrentUser()
                vm.fetchRecentMessages()
            })
        }
        .sheet(isPresented: $vm.shouldShowNewChatView) {
            CreateNewMessageView { user in
                self.selectedChatUser = user
                self.vm.shouldNavigateToChatLogView = true
            }
        }
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            ActionSheet(
                title: Text("Settings"),
                message: Text("What would you like to do?"),
                buttons: [
                    .destructive(Text("Sign Out"), action: {
                        vm.handleSignOut()
                    }),
                    .cancel()
                ]
            )
        }
        .accessibilityIdentifier("MainMessagesView")
    }
    
    private var customNavBar: some View {
        HStack(spacing: 14) {
            if let user = vm.chatUser, let url = URL(string: user.profileImageUrl), !user.profileImageUrl.isEmpty {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color(.separator), lineWidth: 1))
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(vm.chatUser?.username ?? "Current User")
                    .font(.system(size: 20, weight: .bold))
                
                HStack(spacing: 4) {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 8, height: 8)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.primary)
            }
            .accessibilityIdentifier("SettingsSignOutButton")
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
    }
    
    private var messagesView: some View {
        ScrollView {
            if vm.recentMessages.isEmpty {
                VStack(spacing: 12) {
                    Spacer(minLength: 80)
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 56))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No Recent Messages")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Tap the floating button below to start a new conversation.")
                        .font(.subheadline)
                        .foregroundColor(.secondary.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(vm.recentMessages) { recentMessage in
                        Button {
                            let targetId = recentMessage.fromId == FirebaseManager.shared.auth.currentUser?.uid ? recentMessage.toId : recentMessage.fromId
                            self.selectedChatUser = ChatUser(
                                uid: targetId,
                                email: recentMessage.email,
                                profileImageUrl: recentMessage.profileImageUrl
                            )
                            self.vm.shouldNavigateToChatLogView = true
                        } label: {
                            HStack(spacing: 14) {
                                if let url = URL(string: recentMessage.profileImageUrl), !recentMessage.profileImageUrl.isEmpty {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 52, height: 52)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color(.separator), lineWidth: 0.5))
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 52, height: 52)
                                        .foregroundColor(.gray)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(recentMessage.username)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.primary)
                                    Text(recentMessage.text)
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                Spacer()
                                
                                Text(recentMessage.timeAgo)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                        }
                        .accessibilityIdentifier("RecentMessageRow_\(recentMessage.id ?? "")")
                        
                        Divider()
                            .padding(.leading, 80)
                    }
                }
            }
        }
        .accessibilityIdentifier("RecentMessagesScrollView")
    }
    
    private var newMessageFloatingButton: some View {
        Button {
            vm.shouldShowNewChatView.toggle()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                Text("New Message")
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [Color.blue, Color.purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(30)
            .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
        .accessibilityIdentifier("FloatingNewMessageButton")
    }
}

#Preview {
    MainMessagesView()
}
