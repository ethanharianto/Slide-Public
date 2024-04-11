//  searchMessagesByUsername.swift
//  Slide
//  Created by Ethan Harianto on 8/24/23.

import FirebaseAuth
import FirebaseFirestore

func searchMessagesByUsername(username: String, completion: @escaping ([String]) -> Void) {
    let user = Auth.auth().currentUser
    let query = db.collection("Users")
        .whereField("Username", isGreaterThanOrEqualTo: username)
        .whereField("Username", isLessThan: username + "z")
        .whereField("Username", isNotEqualTo: user?.displayName ?? "SimUser")
    query.getDocuments { snapshot, error in
        if let error = error {
            print("Error searching users: \(error.localizedDescription)")
            completion([])
            return
        }
        var users: [String] = []
        for document in snapshot?.documents ?? [] {
            let userID = document.documentID
            users.append(userID)
        }
        completion(users)
    }
}
