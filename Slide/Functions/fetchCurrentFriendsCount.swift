//
//  fetchCurrentFriendsCount.swift
//  Slide
//
//  Created by Ethan Harianto on 8/11/23.
//

import Foundation
import SwiftUI
import FirebaseAuth

func fetchCurrentFriendsCount(highlightHolder: ProfileInfo) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
        
    // Fetch user data from Firestore using the uid
    db.collection("Users").document(uid).getDocument { snapshot, error in
        if let error = error {
            print("Error fetching user data: \(error)")
            return
        }
            
        if let data = snapshot?.data(), let friendsCount = data["Friends"] as? [String] {
            highlightHolder.friendsCount = friendsCount.count
        }
    }
}
