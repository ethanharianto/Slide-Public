//
//  PendingRequests.swift
//  Slide
//
//  Created by Ethan Harianto on 7/30/23.
//

import FirebaseAuth
import SwiftUI

struct PendingRequests: View {
    @Binding var pendingFriendRequests: [UserData]
    @Binding var refreshPending: Bool
    @State private var showingConfirmationDialog = false
    let user = Auth.auth().currentUser
    @State private var isPresented = false
    @State private var selectedUser: UserData? = nil

    var body: some View {
        ForEach(pendingFriendRequests, id: \.userID) { friend in
            HStack {
                UserProfilePictures(photoURL: friend.photoURL, dimension: 45)
                Text(friend.username)
                    .foregroundColor(.primary)
                Spacer()
                if friend.added ?? false {
                    Button {} label: {
                        Image(systemName: "person.2")
                            .padding(5)
                            .foregroundColor(.gray)
                            .background(.primary)
                            .cornerRadius(10)
                    }
                } else {
                    Button {
                        confirmFriendship(u1: user?.uid ?? "SimUser", u2: friend.userID)
                        refreshPending.toggle()
                    } label: {
                        Text("Accept")
                            .foregroundColor(.primary)
                            .padding(5)
                            .padding(.horizontal, 5)
                            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.accentColor))
                    }
                }
                Button {
                    rejectFriendship(u1: user?.uid ?? "SimUser", u2: friend.userID)
                    refreshPending.toggle()
                } label: {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                        .foregroundColor(.gray)
                }
            }
            .onTapGesture {
                selectedUser = friend
                isPresented.toggle()
            }
            .buttonStyle(.borderless)
        }
        .sheet(isPresented: $isPresented) {
            UserProfileView(user: $selectedUser)
        }
    }
}

struct PendingRequests_Previews: PreviewProvider {
    static var previews: some View {
        PendingRequests(pendingFriendRequests: .constant([UserData(userID: "mwahah", username: "tomholland", photoURL: "https://static.foxnews.com/foxnews.com/content/uploads/2023/07/GettyImages-1495234870.jpg", added: false)]), refreshPending: .constant(false))
    }
}
