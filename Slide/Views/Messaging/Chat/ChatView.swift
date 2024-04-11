import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct ChatView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let chatUser: ChatUser?
    @State private var username = ""
    @State private var profileView = false
    @State private var selectedUser: UserData? = nil

    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self.vm = .init(chatUser: chatUser)
    }

    static let emptyScrollToString = "Empty"

    @ObservedObject var vm: ChatViewModel

    var body: some View {
        if profileView {
            UserProfileView(user: $selectedUser)
        } else {
            VStack {
                HStack {
                    Button { self.presentationMode.wrappedValue.dismiss() } label: {
                        Image(systemName: "chevron.left")
                    }
                    .padding(.leading)
                    Spacer()
                    Button {
                        selectedUser = UserData(userID: chatUser!.uid, username: username, photoURL: chatUser?.profileImageUrl ?? "", added: true)
                        withAnimation {
                            profileView.toggle()
                        }
                    } label: {
                        HStack {
                            UserProfilePictures(photoURL: chatUser?.profileImageUrl ?? "", dimension: 50)
                                .foregroundColor(.primary)
                            Text(username)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                    }

                    Spacer()
                }
                ScrollView {
                    ScrollViewReader { scrollViewProxy in
                        ForEach(vm.chatMessages) { message in
                            VStack {
                                if message.sender == Auth.auth().currentUser?.uid {
                                    HStack {
                                        Spacer()
                                        HStack {
                                            Text(message.text)
                                                .font(.system(size: 20))
                                                .foregroundColor(.white)
                                                .padding(7)
                                        }
                                        .frame(minWidth: 30) // Base width
                                        .background(Color.accentColor)
                                        .cornerRadius(12)
                                    }
                                    .padding(.horizontal)
                                } else {
                                    HStack {
                                        HStack {
                                            Text(message.text)
                                                .font(.system(size: 20))
                                                .foregroundColor(.white)
                                                .padding(7)
                                        }
                                        .frame(minWidth: 30) // Base width
                                        .background(Color.darkGray)
                                        .cornerRadius(12)
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        HStack { Spacer() }
                            .id(Self.emptyScrollToString)
                            .onReceive(vm.$count) { _ in
                                withAnimation(.easeOut(duration: 0.5)) {
                                    scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                                }
                            }
                    }
                }
            }
            .onAppear {
                fetchUsernameAndPhotoURL(for: chatUser?.uid ?? "") { name, _ in
                    username = name ?? ""
                }
            }
            .navigationBarBackButtonHidden(true)

            HStack {
                TextField("Send a chat", text: $vm.chatText)
                    .bubbleStyle(color: .primary)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1)
                    .onSubmit {
                        if !vm.chatText.isEmpty {
                            vm.handleSend()
                        }
                    }
                Button(action: {
                    if !vm.chatText.isEmpty {
                        vm.handleSend()
                    }
                }) {
                    Image(systemName: "arrow.up")
                        .foregroundColor(.white)
                        .padding(5)
                        .background(vm.chatText.isEmpty ? .gray : .accentColor)
                        .cornerRadius(15)
                }
            }
            .padding()
            .background(Color.darkGray)
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(chatUser: .init(uid: "", profileImageUrl: ""))
    }
}
