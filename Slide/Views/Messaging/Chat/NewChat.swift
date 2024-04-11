// NewChat.swift
// Slide
// Created by Nidhish Jain on 7/21/23.

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct NewChat: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State public var searchMessages = ""
    @State private var friendList: [(String, String)] = []
    @State private var idList: [String] = []
    @State private var selectedUser: UserData? = nil
    @State private var profileView = false
    @State private var chatView = false
    @State private var chatUser: ChatUser? = nil

    var body: some View {
        if !profileView && !chatView {
            VStack {
                HStack {
                    Button { presentationMode.wrappedValue.dismiss() } label: {
                        Image(systemName: "chevron.left")
                    }
                    .padding(.leading)
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("New Message", text: $searchMessages)
                    }
                    .checkMarkTextField()
                    .bubbleStyle(color: .primary)
                    .padding()
                }
                .padding()
                .padding(.bottom, -10)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach(Array(friendList.enumerated()), id: \.element.0) { index, element in
                            let (friendId, photoURL) = element
                            if friendId.starts(with: searchMessages.lowercased()) || searchMessages.isEmpty {
                                VStack {
                                    UserProfilePictures(photoURL: photoURL, dimension: 50)
                                    Text(friendId)
                                        .foregroundColor(.primary)
                                    Button {
                                        withAnimation {
                                            chatUser = ChatUser(uid: idList[index], profileImageUrl: photoURL)
                                            chatView.toggle()
                                        }
                                    } label: {
                                        Text("Chat")
                                            .padding(-2.5)
                                            .filledBubble()
                                    }

                                    .padding(.top, -12.5)
                                }
                                .frame(width: 125, height: 125)
                                .padding()
                                .bubbleStyle(color: .primary)
                                .background(RoundedRectangle(cornerRadius: 15).foregroundColor(Color.darkGray))
                                .onTapGesture {
                                    withAnimation {
                                        selectedUser = UserData(userID: idList[index], username: friendId, photoURL: photoURL, added: true)
                                        profileView.toggle()
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .onAppear {
                    fetchFriendList()
                }
                .refreshable {
                    fetchFriendList()
                }
            }
            .navigationBarBackButtonHidden(true)
        } else {
            if profileView {
                UserProfileView(user: $selectedUser)
            } else {
                ChatView(chatUser: chatUser)
            }
        }
    }

    func fetchFriendList() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        let userDocumentRef = db.collection("Users").document(currentUserID)
        let dispatchGroup = DispatchGroup()
        // Step 1: Access the User document using the given document ID
        userDocumentRef.getDocument { document, _ in
            if let document = document, document.exists {
                let friendIdList = document.data()?["Friends"] as? [String] ?? []
                for friendId in friendIdList {
                    dispatchGroup.enter() // Enter the DispatchGroup before starting an asynchronous task
                    // Fetch username from the "Users" database using the userDocumentID
                    fetchUsernameAndPhotoURL(for: friendId) { username, photoURL in
                        if let username = username, let photoURL = photoURL {
                            if !self.friendList.contains(where: { $0.0 == username }) {
                                friendList.append((username, photoURL))
                                idList.append(friendId)
                            }
                            dispatchGroup.leave() // Leave the DispatchGroup when the task is complete
                        }
                    }
                }
                self.friendList = friendList
            }
        }
    }
}

struct NewChat_Previews: PreviewProvider {
    static var previews: some View {
        NewChat()
    }
}
