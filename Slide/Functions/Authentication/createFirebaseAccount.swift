//
//  createFirebaseAccount.swift
//  Slide
//
//  Created by Ethan Harianto on 7/14/23.
//

import FirebaseAuth
import Foundation

func createFirebaseAccount(email: String, password: String, username: String, completion: @escaping (String) -> Void) {
    if email.isEmpty || username.isEmpty || password.isEmpty {
        completion("Oops, you did not fill out all the fields.")
        return
    }
    
//    if let result = generateSaltedHash(for: "your_input_string", cycles: 1) {
//        let (hashedValue, salt, cycles) = result
//        print("Hashed value: \(hashedValue.map { String(format: "%02hhx", $0) }.joined())")
//        print("Salt value: \(salt.map { String(format: "%02hhx", $0) }.joined())")
//        print("Cycles: \(cycles)")
//    } else {
//        print("Hash generation failed.")
//    }


    if email.hasSuffix("@stanford.edu") {
//    if true {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error.localizedDescription)
            } else if let result = result {
                // Send email verification
                result.user.sendEmailVerification { error in
                    if let error = error {
                        completion("Error sending verification email: \(error.localizedDescription)")
                    } else {
                        completion("Verification email sent. Please check your inbox.")
                    }
                }
                
                let changeRequest = result.user.createProfileChangeRequest()
                changeRequest.displayName = username.lowercased()
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("Error committing profile changes: \(error)")
                    }
                }
                
                let errorMessage = addUserToDatabases(username: username, email: email, google: false, profilePic: "")
                completion(errorMessage)
            }
        }
    } else {
        completion("Slide isn't available at your school yet!")
    }
}
