//
//  SearchResult.swift
//  Slide
//
//  Created by Ethan Harianto on 9/21/23.
//

import SwiftUI

struct SearchResult: View {
    var user: UserData
    @State private var tapped = false
    @State private var selectedUser: UserData? = nil
    @State private var isPresented = false

    var body: some View {
        HStack {
            UserProfilePictures(photoURL: user.photoURL, dimension: 40)
            Text(user.username)
                .foregroundColor(.white)
            Spacer()
            Button {
                withAnimation {
                    sendFriendRequest(selectedUser: user)
                    tapped.toggle()
                }
            } label: {
                Text(tapped ? "Requested" : "Request")
                    .foregroundColor(tapped ? .gray : .primary)
                    .padding(tapped ? 2.5 : 5)
                    .padding(.horizontal)
                    .background(RoundedRectangle(cornerRadius: 10).foregroundColor(tapped ? .primary : .accentColor))
            }
        }
        .onTapGesture {
            selectedUser = user
            isPresented.toggle()
        }
        .onAppear {
            tapped = user.added ?? false
        }
        .buttonStyle(BorderlessButtonStyle())
        .sheet(isPresented: $isPresented) {
            UserProfileView(user: $selectedUser)
        }
    }
}

#Preview {
    SearchResult(user: UserData(userID: "", username: "", photoURL: ""))
}
