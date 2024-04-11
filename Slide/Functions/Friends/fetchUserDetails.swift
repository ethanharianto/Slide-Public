//  fetchUserDetails.swift
//  Slide
//  Created by Ethan Harianto on 7/30/23.

import Foundation
import FirebaseFirestore
import FirebaseAuth

func fetchUserDetails(userID: String, completion: @escaping (UserData?) -> Void) {
    let user = Auth.auth().currentUser
    db.collection("Users").document(userID).getDocument { document, error in
        if let error = error {
            print("Error fetching user details: \(error.localizedDescription)")
            completion(nil) // Call completion with nil in case of an error
            return
        }

        // Check if the document exists and contains the required fields
        if let document = document,
           let username = document.data()?["Username"] as? String,
           let photoURL = document.data()?["ProfilePictureURL"] as? String,
           let incoming = document.data()?["Incoming"] as? [String],
           let friends = document.data()?["Friends"] as? [String]
        {
            let added = incoming.contains(user?.uid ?? "SimUser") || friends.contains(user?.uid ?? "SimUser")
            let userDetails = UserData(userID: userID, username: username, photoURL: photoURL, added: added)
            completion(userDetails)
        }
        else {
            completion(nil) // Call completion with nil if document is missing required fields
        }
    }
}
