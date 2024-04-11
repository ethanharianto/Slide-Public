//  ProfilePicture.swift
//  Slide
//  Created by Ethan Harianto on 8/7/23.

import SwiftUI
import FirebaseAuth

struct ProfilePicture: View {
    var user = Auth.auth().currentUser
    @State private var changeProfilePic = false
    @State private var reloadProfilePic = false
    
    var body: some View {
        Button(action: {
            changeProfilePic = true
        }) {
            UserProfilePictures(photoURL: user?.photoURL?.absoluteString ?? "", dimension: 100)
        }
        .sheet(isPresented: $changeProfilePic) {
            ImageConfirmation(reloadProfilePic: $reloadProfilePic)
        }
        .id(reloadProfilePic)
    }
}
