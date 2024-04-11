//  unfriend.swift
//  Slide
//  Created by Ethan Harianto on 7/31/23.

import Foundation
import FirebaseFirestore
import FirebaseAuth

func unfriend(u2: String) {
    let user = Auth.auth().currentUser!.uid
    if u2 == "" {
        return
    }
    // First update the first user
    let u1DocRef = db.collection("Users").document(user)
    // Step 1: Access the User document using the given document ID
    u1DocRef.getDocument { document, _ in
        if let document = document, document.exists {
            var friendsList = document.data()?["Friends"] as? [String] ?? []
            if let index = friendsList.firstIndex(of: u2) {
                friendsList.remove(at: index)
            }
            u1DocRef.updateData(["Friends": friendsList])
        }
        else {
            print("User document not found!")
        }
    }
    // Now update user2
    let u2DocRef = db.collection("Users").document(u2)
    // Step 1: Access the User document using the given document ID
    u2DocRef.getDocument { document, _ in
        if let document = document, document.exists {
            var friendsList = document.data()?["Friends"] as? [String] ?? []
            if let index = friendsList.firstIndex(of: user) {
                friendsList.remove(at: index)
            }
            u2DocRef.updateData(["Friends": friendsList])
        }
        else {
            print("User document not found!")
        }
    }
}
