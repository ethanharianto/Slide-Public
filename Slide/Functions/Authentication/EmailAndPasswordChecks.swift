//
//  EmailAndPasswordChecks.swift
//  Slide
//
//  Created by Ethan Harianto on 7/20/23.
//

import Foundation
import FirebaseFirestore

func isPasswordValid(_ password: String) -> String {
    let obviousPasswords = [
        "12345678",
        "123456",
        "qwerty",
        "abcdef",
        // Add more obvious passwords as needed
    ]

    // Check if the password is at least 8 characters long
    guard password.count >= 8 else {
        return "Your password is too short."
    }

    // Check if the password is not an obvious password
    if obviousPasswords.contains(where: { password.lowercased().contains($0.lowercased()) }) {
        return "Your password is too obvious."
    }

    // Password meets all criteria
    return ""
}

func isEmailValid(_ email: String) -> String {
    let validEmails = [
        "stanford.edu",
    ]

    let domain = email.components(separatedBy: "@").last

    if validEmails.contains(domain ?? "") {
        return ""
    }

    // Password meets all criteria
    return "Oops, Slide isn't available for your school yet!"
//    return ""
}

func isGoogleUser(email: String, completion: @escaping (Bool, Error?) -> Void) {
    let emailRef = db.collection("Usernames")
        .whereField("Email", isEqualTo: email.lowercased())
                    .limit(to: 1)
    
    emailRef.getDocuments { (querySnapshot, error) in
        if let error = error {
            completion(false, error)
            return
        }
        
        if let document = querySnapshot?.documents.first {
            // Access the "google" field's value from the document data
            if let googleField = document.data()["Google"] as? Bool {
                // Return true if the "google" field is true
                completion(googleField, nil)
            } else {
                // If "google" field is missing or not a Bool value, return false
                completion(false, nil)
            }
        } else {
            // User not found, return false
            completion(false, nil)
        }
    }
}


