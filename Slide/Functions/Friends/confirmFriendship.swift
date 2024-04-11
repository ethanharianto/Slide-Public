//  confirmFriendship.swift
//  Slide
//  Created by Ethan Harianto on 7/30/23.

import Foundation
import FirebaseFirestore

func confirmFriendship(u1: String, u2: String) {
    if u1 == "" || u2 == "" {
        return
    }
    // First update the first user
    let u1DocRef = db.collection("Users").document(u1)
    // Step 1: Access the User document using the given document ID
    u1DocRef.getDocument { document, _ in
        if let document = document, document.exists {
            var incomingList = document.data()?["Incoming"] as? [String] ?? []
            var outgoingList = document.data()?["Outgoing"] as? [String] ?? []
            var friendList = document.data()?["Friends"] as? [String] ?? []
            if let index = incomingList.firstIndex(of: u2) {
                incomingList.remove(at: index)
            }
            if let index = outgoingList.firstIndex(of: u2) {
                outgoingList.remove(at: index)
            }
            friendList.append(u2)
            u1DocRef.updateData(["Friends": friendList])
            u1DocRef.updateData(["Outgoing": outgoingList])
            u1DocRef.updateData(["Incoming": incomingList])
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
            var incomingList = document.data()?["Incoming"] as? [String] ?? []
            var outgoingList = document.data()?["Outgoing"] as? [String] ?? []
            var friendList = document.data()?["Friends"] as? [String] ?? []
            if let index = incomingList.firstIndex(of: u1) {
                incomingList.remove(at: index)
            }
            if let index = outgoingList.firstIndex(of: u1) {
                outgoingList.remove(at: index)
            }
            friendList.append(u1)
            u2DocRef.updateData(["Friends": friendList])
            u2DocRef.updateData(["Outgoing": outgoingList])
            u2DocRef.updateData(["Incoming": incomingList])
        }
        else {
            print("User document not found!")
        }
    }
}
