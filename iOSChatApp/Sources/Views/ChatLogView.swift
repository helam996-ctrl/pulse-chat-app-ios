import SwiftUI

public struct ChatLogView: View {
    let chatUser: ChatUser?
    
    @StateObject private var vm: ChatLogViewModel
    
    public init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self._vm = StateObject(wrappedValue: ChatLogViewModel(chatUser: chatUser))
    }
    
    private static let bottomScrollID = "BOTTOM_SCROLL_ID"
    
    public var body: some View {
        VStack(spacing: 0) {
            messagesScrollView
            chatBottomBar
        }
        .navigationTitle(chatUser?.username ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    if let user = chatUser, let url = URL(string: user.profileImageUrl), !user.profileImageUrl.isEmpty {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Circle().fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(chatUser?.username ?? "Chat")
                            .font(.headline)
                        Text("Online")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(vm.chatMessages) { message in
                        MessageBubbleView(message: message)
                            .id(message.id ?? UUID().uuidString)
                    }
                    
                    HStack { Spacer() }
                        .id(Self.bottomScrollID)
                        .frame(height: 8)
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
            .onChange(of: vm.count) { _ in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    proxy.scrollTo(Self.bottomScrollID, anchor: .bottom)
                }
            }
            .onAppear {
                proxy.scrollTo(Self.bottomScrollID, anchor: .bottom)
            }
        }
        .accessibilityIdentifier("ChatMessagesScrollView")
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $vm.chatText, axis: .vertical)
                .lineLimit(1...5)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .accessibilityIdentifier("ChatMessageInputTextField")
            
            Button {
                vm.handleSend()
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(vm.chatText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                    )
            }
            .disabled(vm.chatText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .accessibilityIdentifier("SendMessageButton")
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
    }
}

public struct MessageBubbleView: View {
    let message: ChatMessage
    
    public var body: some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer(minLength: 40)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.text)
                        .foregroundColor(.white)
                        .font(.body)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color(red: 0.1, green: 0.45, blue: 0.95)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(18)
                    
                    Text(message.formattedTime)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 4)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.text)
                        .foregroundColor(.primary)
                        .font(.body)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(18)
                    
                    Text(message.formattedTime)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.leading, 4)
                }
                
                Spacer(minLength: 40)
            }
        }
    }
}

#Preview {
    NavigationView {
        ChatLogView(chatUser: ChatUser(uid: "sample123", email: "sample@college.edu", profileImageUrl: ""))
    }
}
