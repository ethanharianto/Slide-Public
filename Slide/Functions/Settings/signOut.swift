//
//  SignOut.swift
//  Slide
//
//  Created by Ethan Harianto on 7/25/23.
//

import Foundation
import FirebaseAuth

// signs out the current user
func signOut() {
    let auth = Auth.auth()
    do {
        try auth.signOut()
        print("signed out")
    } catch let signOutError as NSError {
        print("Error signing out: %@" + signOutError.localizedDescription)
    }
}
