//
//  updateUsername.swift
//  Slide
//
//  Created by Ethan Harianto on 7/26/23.
//

import FirebaseAuth
import Foundation

func updateUsername(username: String, completion: @escaping (String) -> Void) {
    let user = Auth.auth().currentUser
    var usernameRef = db.collection("Usernames").document(username.lowercased())
    usernameRef.getDocument { document, error in
        if let error = error {
            completion("Error checking username: \(error.localizedDescription)")
            return
        }
        
        if let document = document, document.exists {
            // The username is already taken, handle this scenario (e.g., show an error message)
            completion("")
        } else {
            // The username is available, update the display name
            usernameRef = db.collection("Usernames").document(user?.displayName ?? "SimUser")
            usernameRef.getDocument { document, error in
                if let error = error {
                    print(error.localizedDescription)
                    completion("oops")
                }
                
                if let document = document, document.exists {
                    let data = document.data()
                    db.collection("Usernames").document(username.lowercased()).setData(data!) { error in
                        if let error = error {
                            print("Error adding document: \(error)")
                        }
                    }
                    usernameRef.delete() { error in
                        print(error?.localizedDescription as Any)
                    }
                    let changeRequest = user!.createProfileChangeRequest()
                    changeRequest.displayName = username.lowercased()
                    changeRequest.commitChanges { error in
                        if let error = error {
                            completion("Error updating display name: \(error.localizedDescription)")
                        } else {
                            // Now the display name is updated, call the completion handler with the username
                            let userRef = db.collection("Users").document(user?.uid ?? "Sim User")
                            userRef.updateData(["Username": username.lowercased()]) { error in
                                if let error = error {
                                    print("Error adding document: \(error)")
                                }
                            }
                            completion(username)
                        }
                    }
                } 
            }
        }
    }
}
