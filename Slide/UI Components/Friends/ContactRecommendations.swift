//
//  ContactRecommendations.swift
//  Slide
//
//  Created by Ethan Harianto on 9/11/23.
//

import SwiftUI

struct ContactRecommendations: View {
    @Binding var contacts: Set<UserData>
    @State private var showingConfirmationDialog = false
    @State private var isPresented = false
    @State private var selectedUser: UserData? = nil
    
    var body: some View {
        ForEach(Array(contacts), id: \.self) { friend in
            HStack {
                UserProfilePictures(photoURL: friend.photoURL, dimension: 40)
                Text(friend.username)
                    .foregroundColor(.white)

                Spacer()
                if friend.added ?? false {
                    Button {} label: {
                        HStack {
                            Text("Requested")
                        }
                        .padding(5)
                        .foregroundColor(.gray)
                        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.primary))
                    }
                } else {
                    Button {
                        sendFriendRequest(selectedUser: friend)
                        if let index = Array(contacts).firstIndex(where: { $0.userID == friend.userID }) {
                            var updatedContacts = Array(contacts)
                            updatedContacts[index].added = true
                            contacts = Set(updatedContacts)
                        }
                    } label: {
                        Text("Request")
                            .foregroundColor(.primary)
                            .padding(5)
                            .padding(.horizontal)
                            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.accentColor))
                    }
                }
            }
            .onTapGesture {
                selectedUser = friend
                isPresented.toggle()
            }
            .sheet(isPresented: $isPresented) {
                UserProfileView(user: $selectedUser)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}

struct ContactRecommendations_Previews: PreviewProvider {
    static var previews: some View {
        ContactRecommendations(contacts: .constant([]))
    }
}
