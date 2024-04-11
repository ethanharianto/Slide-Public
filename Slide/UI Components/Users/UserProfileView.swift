//
//  UserProfileView.swift
//  Slide
//
//  Created by Ethan Harianto on 7/31/23.
//

import SwiftUI

struct UserProfileView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var user: UserData?
    @State private var chat = false
    @State private var username = ""

    var body: some View {
        if chat {
            ChatView(chatUser: ChatUser(uid: user!.userID, profileImageUrl: user!.photoURL))
        } else {
            VStack {
                HStack {
                    Button { self.presentationMode.wrappedValue.dismiss() } label: {
                        Image(systemName: "chevron.left")
                    }
                    .padding(.leading)
                    Spacer()
                    Menu {
                        Button("Block") {}
                        Button("Unfriend") {
                            unfriend(u2: user!.userID)
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    .padding()
                    .foregroundColor(.gray)
                }

                UserProfilePictures(photoURL: user!.photoURL, dimension: 125)
                Text(username)
                    .fontWeight(.semibold)
                Button {
                    chat = true
                } label: {
                    Text("Message")
                        .filledBubble()
                }
                .frame(width: 150)
                .padding()
                Spacer()
            }
            .onAppear {
                fetchUsernameAndPhotoURL(for: user!.userID) { name, _ in
                    username = name ?? ""
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(user: .constant(UserData(userID: "mwahah", username: "baesuzy", photoURL: "https://m.media-amazon.com/images/M/MV5BZWQ5YTFhZDAtMTg3Yi00NzIzLWIyY2EtNDQ2YWNjOWJkZWQxXkEyXkFqcGdeQXVyMjQ2OTU4Mjg@._V1_.jpg", added: false)))
    }
}
