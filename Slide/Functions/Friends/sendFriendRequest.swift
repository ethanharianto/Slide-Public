//  sendFriendRequest.swift
//  Slide
//  Created by Ethan Harianto on 7/30/23.

import FirebaseAuth
import FirebaseStorage
import Foundation

func sendFriendRequest(selectedUser: UserData?) {
    guard let currentUserID = Auth.auth().currentUser?.uid,
          let selectedUserID = selectedUser?.userID
    else {
        return
    }
    // First update the outgoing request
    let currentUserDocumentRef = db.collection("Users").document(currentUserID)
    // Step 1: Access the User document using the given document ID
    currentUserDocumentRef.getDocument { document, error in
        if let document = document, document.exists {
            let incomingList = document.data()?["Incoming"] as? [String] ?? []
            if incomingList.contains(selectedUserID) {
                confirmFriendship(u1: currentUserID, u2: selectedUserID)
            }
            else {
                var outgoingList = document.data()?["Outgoing"] as? [String] ?? []
                // Step 2: Add the new string to the list
                if !outgoingList.contains(selectedUserID) {
                    outgoingList.append(selectedUserID)
                } else {
                    let index = outgoingList.firstIndex(of: selectedUserID)
                    outgoingList.remove(at: index!)
                }
                // Step 3: Update the User document with the modified "Outgoing" field
                currentUserDocumentRef.updateData(["Outgoing": outgoingList]) { error in
                    if let error = error {
                        print("Error updating Outgoing field: \(error)")
                    }
                    else {
                        print("Outgoing field updated successfully!")
                    }
                }
            }
        }
        else {
            print("User document not found!")
        }
    }
    // Now update the incoming request
    let selectedUserDocumentRef = db.collection("Users").document(selectedUserID)
    selectedUserDocumentRef.getDocument { document, error in
        if let document = document, document.exists {
            let outgoingList = document.data()?["Outgoing"] as? [String] ?? []
            if outgoingList.contains(currentUserID) {
                confirmFriendship(u1: currentUserID, u2: selectedUserID)
            }
            else {
                var incomingList = document.data()?["Incoming"] as? [String] ?? []
                // Step 2: Add the new string to the list
                if !incomingList.contains(currentUserID) {
                    incomingList.append(currentUserID)
                } else {
                    let index = incomingList.firstIndex(of: currentUserID)
                    incomingList.remove(at: index!)
                }
                // Step 3: Update the User document with the modified "Outgoing" field
                selectedUserDocumentRef.updateData(["Incoming": incomingList]) { error in
                    if let error = error {
                        print("Error updating Outgoing field: \(error)")
                    }
                    else {
                        print("Outgoing field updated successfully!")
                    }
                }
            }
        }
        else {
            print("User document not found!")
        }
    }
}
