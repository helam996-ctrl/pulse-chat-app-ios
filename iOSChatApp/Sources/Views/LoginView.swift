import SwiftUI

public struct LoginView: View {
    let didCompleteLoginProcess: () -> Void
    
    @StateObject private var vm = LoginViewModel()
    @State private var shouldShowImagePicker = false
    
    public init(didCompleteLoginProcess: @escaping () -> Void) {
        self.didCompleteLoginProcess = didCompleteLoginProcess
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Picker(selection: $vm.isLoginMode, label: Text("Authentication Mode")) {
                        Text("Log In")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .accessibilityIdentifier("AuthModeSegmentedPicker")
                    
                    if !vm.isLoginMode {
                        Button {
                            shouldShowImagePicker.toggle()
                        } label: {
                            VStack(spacing: 8) {
                                if let image = vm.selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .cornerRadius(60)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 60)
                                                .stroke(Color.blue, lineWidth: 2)
                                        )
                                } else {
                                    Image(systemName: "person.crop.circle.badge.plus")
                                        .font(.system(size: 72))
                                        .foregroundColor(.blue)
                                        .frame(width: 120, height: 120)
                                }
                                
                                Text("Select Avatar")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .accessibilityIdentifier("SelectAvatarButton")
                        .padding(.top, 8)
                    }
                    
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.secondary)
                                .frame(width: 24)
                            TextField("Email Address", text: $vm.email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .accessibilityIdentifier("EmailTextField")
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.secondary)
                                .frame(width: 24)
                            SecureField("Password", text: $vm.password)
                                .accessibilityIdentifier("PasswordSecureField")
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Button {
                        vm.handleAction()
                    } label: {
                        HStack {
                            Spacer()
                            if vm.isAuthenticating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 8)
                            }
                            Text(vm.isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(.white)
                                .font(.headline)
                                .padding(.vertical, 14)
                            Spacer()
                        }
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(vm.isAuthenticating)
                    .accessibilityIdentifier("SubmitAuthButton")
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    if !vm.statusMessage.isEmpty {
                        Text(vm.statusMessage)
                            .font(.footnote)
                            .foregroundColor(vm.statusMessage.contains("Success") ? .green : .red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .accessibilityIdentifier("StatusMessageText")
                    }
                    
                    Spacer()
                }
                .padding(.top, 24)
            }
            .navigationTitle(vm.isLoginMode ? "Welcome Back" : "Create Account")
            .background(Color(.systemBackground))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $shouldShowImagePicker) {
            ImagePicker(image: $vm.selectedImage)
        }
        .onChange(of: vm.didCompleteLoginProcess) { completed in
            if completed {
                didCompleteLoginProcess()
            }
        }
    }
}

#Preview {
    LoginView(didCompleteLoginProcess: {})
}
