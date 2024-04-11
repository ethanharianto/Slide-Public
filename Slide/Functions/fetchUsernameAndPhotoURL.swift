//  fetchUsername.swift
//  Slide
//  Created by Ethan Harianto on 7/26/23.

import Foundation
import FirebaseAuth

func fetchUsernameAndPhotoURL(for documentID: String, completion: @escaping (String?, String?) -> Void) {
    let userDocumentRef = db.collection("Users").document(documentID)

    userDocumentRef.getDocument { (document, error) in
        if let document = document, document.exists {
            if let username = document.data()?["Username"] as? String,
               let photoURL = document.data()?["ProfilePictureURL"] as? String {
                completion(username, photoURL)
            } else {
                completion(nil, nil)
            }
        } else {
            print("Error fetching user document: \(error?.localizedDescription ?? "Unknown error")")
            completion(nil, nil)
        }
    }
}
