//  FriendsList.swift
//  Slide
//  Created by Ethan Harianto on 7/31/23.

import SwiftUI

struct FriendsList: View {
    @Binding var friendsList: [UserData]
    @State private var showingConfirmationDialog = false
    @State private var isPresented = false
    @State private var selectedUser: UserData? = nil

    var body: some View {
        ForEach(friendsList, id: \.userID) { friend in
            HStack {
                UserProfilePictures(photoURL: friend.photoURL, dimension: 40)
                Text(friend.username)
                    .foregroundColor(.white)

                Spacer()
            }
            .onTapGesture {
                selectedUser = friend
                isPresented.toggle()
            }
        }
        .sheet(isPresented: $isPresented) {
            UserProfileView(user: $selectedUser)
        }
    }
}

struct FriendsList_Previews: PreviewProvider {
    static var previews: some View {
        FriendsList(friendsList: .constant([UserData(userID: "mwahah", username: "baesuzy", photoURL: "https://m.media-amazon.com/images/M/MV5BZWQ5YTFhZDAtMTg3Yi00NzIzLWIyY2EtNDQ2YWNjOWJkZWQxXkEyXkFqcGdeQXVyMjQ2OTU4Mjg@._V1_.jpg", added: false), UserData(userID: "mwahahah", username: "tomholland", photoURL: "https://static.foxnews.com/foxnews.com/content/uploads/2023/07/GettyImages-1495234870.jpg", added: false)]))
    }
}
