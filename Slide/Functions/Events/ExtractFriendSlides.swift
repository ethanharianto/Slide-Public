//
//  ExtractFriendSlides.swift
//  Slide
//
//  Created by Thomas on 8/19/23.
//

import Foundation

import Foundation
import SwiftUI
import FirebaseAuth


func extractFriendSlides(event: Event, completion: @escaping ([String], [String]) -> Void) {
    fetchCurrentFriends { friends in
        let currentFriends = friends
        let slides = event.slides
                
        let slidesSet = Set(slides)
        let currentFriendsSet = Set(currentFriends)
        
        let friendSlidesSet = slidesSet.intersection(currentFriendsSet)
        let nonFriendSlidesSet = slidesSet.subtracting(currentFriendsSet).subtracting(Set([Auth.auth().currentUser!.uid]))
        
        let friendSlides = Array(friendSlidesSet)
        let nonFriendSlides = Array(nonFriendSlidesSet)
        
        completion(friendSlides, nonFriendSlides)
    }
}


func fetchCurrentFriends(completion: @escaping ([String]) -> Void) {
    var userFriends: [String] = []
    guard let uid = Auth.auth().currentUser?.uid else {
        completion(userFriends)
        return
    }
    
    let group = DispatchGroup() // Create a DispatchGroup

    group.enter()
    // Fetch user data from Firestore using the uid
    db.collection("Users").document(uid).getDocument { snapshot, error in
        if let error = error {
            print("Error fetching user data: \(error)")
            completion(userFriends)
            return
        }
            
        if let data = snapshot?.data(), let friends = data["Friends"] as? [String] {
            userFriends = friends
        }
        group.leave()
    }
    
    group.notify(queue: .main) {
        print(userFriends)
        completion(userFriends)
    }
}
