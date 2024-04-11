//
//  UserSlidedProfileBox.swift
//  Slide
//
//  Created by Thomas on 8/24/23.
//
import SwiftUI
import Kingfisher

struct UserSlidedProfileBox: View {
    
    var uid: String
    @State private var username: String = ""
    @State private var profilePicUrl: String = ""
    var friend: Bool
    @Binding var profileView: Bool
    @Binding var selectedUser: UserData?

    let boxSize: CGFloat = UIScreen.main.bounds.width / 4

    var body: some View {
        HStack {
            UserProfilePictures(photoURL: profilePicUrl, dimension: 25)
                .onTapGesture {
                    selectedUser = UserData(userID: uid, username: username, photoURL: profilePicUrl)
                    profileView.toggle()
                }
            Text(username)
                .font(.headline)
        }
        .padding(-5)
        .bubbleStyle(color: .primary)
        .onAppear {
            fetchUserData()
        }
    }


    func fetchUserData() {
        fetchUsernameAndPhotoURL(for: self.uid) { fetchedUsername, fetchedProfilePicURL in
            DispatchQueue.main.async {
                self.username = fetchedUsername ?? ""
                self.profilePicUrl = fetchedProfilePicURL ?? ""
            }
        }
    }

}
