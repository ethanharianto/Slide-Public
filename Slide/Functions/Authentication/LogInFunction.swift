//
//  LogIn.swift
//  Slide
//
//  Created by Ethan Harianto on 7/15/23.
//

import FirebaseFirestore
import FirebaseAuth

func login(email: String, password: String, completion: @escaping (String) -> Void) {
    Auth.auth().signIn(withEmail: email, password: password) { _, error in
        if let error = error {
            let err = error as NSError
            if let authErrorCode = AuthErrorCode.Code(rawValue: err.code) {
                switch authErrorCode {
                case .invalidEmail:
                    searchUserByUsername(username: email.lowercased()) { document, _ in
                        if let document = document {
                            if let emailValue = document.get("Email") as? String {
                                login(email: emailValue, password: password, completion: completion)
                            } else {
                                completion("Invalid username")
                            }
                        } else {
                            completion("Invalid username")
                        }
                    }
                case .wrongPassword:
                    completion("Invalid password")
                default:
                    completion(error.localizedDescription)
                }
            }
        } else {
            completion("") // No error, empty string
        }
    }
}

func searchUserByUsername(username: String, completion: @escaping (DocumentSnapshot?, Error?) -> Void) {
    let usernameRef = db.collection("Usernames").document(username)
    
    usernameRef.getDocument { (document, error) in
        if let error = error {
            completion(nil, error)
            return
        }
        
        completion(document, nil)
    }
}
