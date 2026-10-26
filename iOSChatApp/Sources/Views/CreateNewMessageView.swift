import SwiftUI

public struct CreateNewMessageView: View {
    let didSelectUser: (ChatUser) -> Void
    
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var vm = CreateNewMessageViewModel()
    
    public init(didSelectUser: @escaping (ChatUser) -> Void) {
        self.didSelectUser = didSelectUser
    }
    
    public var body: some View {
        NavigationView {
            Group {
                if vm.isLoading {
                    ProgressView("Loading Users...")
                } else if !vm.errorMessage.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 44))
                            .foregroundColor(.orange)
                        Text(vm.errorMessage)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Retry") {
                            vm.fetchAllUsers()
                        }
                    }
                } else if vm.users.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 44))
                            .foregroundColor(.secondary)
                        Text("No other registered users found.")
                            .foregroundColor(.secondary)
                    }
                } else {
                    List(vm.users) { user in
                        Button {
                            presentationMode.wrappedValue.dismiss()
                            didSelectUser(user)
                        } label: {
                            HStack(spacing: 16) {
                                if let url = URL(string: user.profileImageUrl), !user.profileImageUrl.isEmpty {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color(.separator), lineWidth: 1))
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.gray)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.username)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(user.email)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            .padding(.vertical, 4)
                        }
                        .accessibilityIdentifier("UserRow_\(user.uid)")
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("New Message")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }.accessibilityIdentifier("CancelNewMessageButton"))
        }
        .accessibilityIdentifier("CreateNewMessageNavigationView")
    }
}

#Preview {
    CreateNewMessageView(didSelectUser: { _ in })
}
