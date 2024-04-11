//  AddUser.swift
//  Slide
//  Created by Ethan Harianto on 7/14/23.

import FirebaseAuth
import FirebaseFirestore
import Foundation

func addUserToDatabases(username: String, email: String, google: Bool, profilePic: String) -> String {
    let stanfordUID = "UuWof49tbwPsq2lZxchVERvtx3I3"
    
    guard let user = Auth.auth().currentUser else {
        return "User is not signed in."
    }
    
    let uid = user.uid
    let username = username.lowercased()
    var errormessage = ""
    
    let usersRef = db.collection("Users").document(uid)
    let usernameRef = db.collection("Usernames").document(username)
    
    usersRef.getDocument { document, error in
        if let error = error {
            print("Error fetching document: \(error)")
            return
        }
        if let document = document, document.exists {
            errormessage = "Username taken."
        } else {
            let userData: [String: Any] = [
                "Email": email,
                "Username": username,
                "ProfilePictureURL": profilePic ,
                "Phone Number" : "",
                "Incoming": [String](),
                "Outgoing": [String](),
                "Friends": [stanfordUID],
                "Blocked": [String]()
            ]
            usersRef.setData(userData) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                    errormessage = error.localizedDescription
                }
            }
        }
    }
    
    let stanfordRef = db.collection("Users").document(stanfordUID)
    stanfordRef.getDocument { document, error in
        if error != nil {
            return
        }
        if let document = document, document.exists {
            var curFriends = document.data()?["Friends"] as? [String] ?? []
            curFriends.append(uid)
            stanfordRef.updateData(["Friends": curFriends])
        }
    }
    
    usernameRef.getDocument { document, error in
        if let error = error {
            print("Error fetching document: \(error)")
            return
        }
        if let document = document, document.exists {
            errormessage = "Username taken."
        } else {
            let data: [String: Any] = [
                "Email": email,
                "Google": google,
            ]
            usernameRef.setData(data) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                    errormessage = error.localizedDescription
                }
            }
        }
    }
    
    return errormessage
}
