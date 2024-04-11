//
//  googleSignIn.swift
//  Slide
//
//  Created by Ethan Harianto on 7/14/23.
//

import Firebase
import Foundation
import GoogleSignIn
import UIKit

func googleSignIn(registered: Bool, completion: @escaping (String) -> Void) {
    guard let clientID = FirebaseApp.app()?.options.clientID else {
        completion("Client ID not found.")
        return
    }
    
    let config = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = config
    
    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let windowDelegate = scene.delegate as? UIWindowSceneDelegate,
       let window = windowDelegate.window,
       let rootViewController = window?.rootViewController
    {
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signResult, error in
            if let error = error {
                completion(error.localizedDescription)
                return
            }
            
            guard let gUser = signResult?.user,
                  let idToken = gUser.idToken
            else {
                completion("Failed to get user or ID token.")
                return
            }
            let email = gUser.profile?.email ?? ""
            let accessToken = gUser.accessToken
            
            if !email.hasSuffix("@stanford.edu") {
                completion("Slide isn't available at your school yet!")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
            let group = DispatchGroup()
            group.enter()
            // Use the credential to authenticate with Firebase
            Auth.auth().signIn(with: credential) { _, error in
                if let error = error {
                    completion(error.localizedDescription)
                }
                group.leave()
            }
            var errorMessage = ""
            
            group.notify(queue: .main) {
                let user = Auth.auth().currentUser
                let username = email.components(separatedBy: "@").first?.lowercased()
                let usernameRef = db.collection("Usernames").whereField("Email", isEqualTo: email.lowercased())
                usernameRef.getDocuments { document, error in
                    if let error = error {
                        completion("Error checking username: \(error.localizedDescription)")
                        return
                    }
                    if let document = document {
                        // The username is already taken, handle this scenario (e.g., show an error message)
                        if document.isEmpty {
                            errorMessage = addUserToDatabases(username: username!, email: email, google: true, profilePic: gUser.profile?.imageURL(withDimension: 120)?.absoluteString ?? "")
                            // The username is available, update the display name
                            let changeRequest = user!.createProfileChangeRequest()
                            changeRequest.displayName = username
                            changeRequest.commitChanges { error in
                                if let error = error {
                                    completion("Error updating display name: \(error.localizedDescription)")
                                } else {
                                    // Now the display name is updated, call the completion handler with the username
                                    completion(username!)
                                }
                            }
                            
                        } else {
                            completion("")
                        }
                    }
                }
                
                if errorMessage.isEmpty {
                    print("no error")
                    completion("") // No error, empty string
                } else {
                    completion(errorMessage)
                }
            }
        }
    } else {
        completion("Failed to get window or root view controller.")
    }
}
