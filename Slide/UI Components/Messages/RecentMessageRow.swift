// RecentMessageRow.swift
// Slide
// Created by Ethan Harianto on 8/3/23.
import Firebase
import SwiftUI
struct RecentMessageRow: View {
    var recentMessage: RecentMessage
    @State private var username = ""
    @State private var photoURL = ""
    @Binding var profileView: Bool
    @Binding var selectedUser: UserData?
    @ObservedObject var vm: MainMessagesViewModel
    @State var isRecentReceived = false

    var body: some View {
        NavigationLink(destination: ChatView(chatUser: ChatUser(uid: recentMessage.toId == Auth.auth().currentUser?.uid ? recentMessage.fromId : recentMessage.toId, profileImageUrl: photoURL))) {
            HStack {
                Button {
                    selectedUser = UserData(userID: recentMessage.toId == Auth.auth().currentUser?.uid ? recentMessage.fromId : recentMessage.toId, username: username, photoURL: photoURL, added: true)
                    withAnimation {
                        profileView.toggle()
                    }
                } label: {
                    UserProfilePictures(photoURL: photoURL, dimension: 50)
                        .clipShape(Circle())
                        .shadow(radius: 15)
                }
                .foregroundColor(.white)
                VStack(alignment: .leading) {
                    Text(username)
                        .fontWeight(.semibold)
                    Text(recentMessage.text)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .font(isRecentReceived ? .system(.body, design: .rounded).bold() : .system(.body, design: .rounded))
                }
                Spacer()
                Text(formatTimestamp(recentMessage.timestamp))
                    .foregroundColor(.gray)
            }
        }
        .buttonStyle(.plain)
        .onAppear {
            fetchUsernameAndPhotoURL(for: recentMessage.toId == Auth.auth().currentUser?.uid ? recentMessage.fromId : recentMessage.toId) { fetchedUsername, profilePic in
                username = fetchedUsername ?? ""
                photoURL = profilePic ?? ""
            }
        }
        .swipeActions(edge: .trailing) {
            Button {
                onHide(message: recentMessage)
            } label: {
                Label("", systemImage: "trash")
            }
        }
        .onAppear {
            if recentMessage.toId == Auth.auth().currentUser?.uid {
                isRecentReceived = true
            }
            else {
                isRecentReceived = false
            }
        }
    }

    func onHide(message: RecentMessage) {
        vm.hideMessage(message)
    }
}

struct RecentMessageRow_Previews: PreviewProvider {
    static var previews: some View {
        RecentMessageRow(recentMessage: RecentMessage(documentId: "", data: ["": ""]), profileView: .constant(false), selectedUser: .constant(UserData(userID: "", username: "", photoURL: "", added: true)), vm: MainMessagesViewModel())
    }
}
