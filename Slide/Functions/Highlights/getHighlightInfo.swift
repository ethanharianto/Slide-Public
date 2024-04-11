//  getHighlightInfo.swift
//  Slide
//  Created by Thomas on 7/27/23.

import Firebase
import FirebaseFirestore
import Foundation

func getHighlightInfo(highlightID: String, completion: @escaping (HighlightInfo?) -> Void) {
    let postsCollectionRef = db.collection("Posts").document(highlightID)

    postsCollectionRef.getDocument { pdocument, _ in
        if let pdocument = pdocument, pdocument.exists {
            if let caption = pdocument.data()?["ImageCaption"] as? String,
               let userDocumentID = pdocument.data()?["User"] as? String,
               let imagePath = pdocument.data()?["PostImage"] as? String,
               let postTime = (pdocument.data()?["PostTime"] as? Timestamp)?.dateValue()
            {
                var likedUsersArray: [String] = []
                if let tempLikedUsersArray = pdocument.data()?["Liked Users"] as? [String] {
                    likedUsersArray = tempLikedUsersArray
                }

                let userCollectionRef = db.collection("Users").document(userDocumentID)
                userCollectionRef.getDocument { document, _ in
                    if let document = document, document.exists {
                        if let username = document.data()?["Username"] as? String,
                           let photoURL = document.data()?["ProfilePictureURL"] as? String
                        {
                            let highlightInfo = HighlightInfo(uid: userDocumentID, postID: pdocument.documentID, imageName: imagePath, profileImageName: photoURL, username: username, highlightTitle: caption, likedUsers: likedUsersArray, postTime: postTime)
                            completion(highlightInfo) // Call the completion handler with the result
                        } else {
                            completion(nil) // Call the completion handler with nil if username is not available
                        }
                    } else {
                        completion(nil) // Call the completion handler with nil if the user document doesn't exist or there was an error
                    }
                }
            } else {
                completion(nil) // Call the completion handler with nil if any of the required data is not available
            }
        } else {
            completion(nil) // Call the completion handler with nil if the document doesn't exist or there was an error
        }
    }
}
