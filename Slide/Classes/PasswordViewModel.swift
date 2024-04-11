//
//  PasswordViewModel.swift
//  Slide
//
//  Created by Ethan Harianto on 9/9/23.
//

import Firebase
import Foundation
import SwiftUI

class PasswordViewModel: ObservableObject {
    @Published var loadingVerify: Bool = false

    @Published var phoneNumber: String = ""
    @Published var verifying: Bool = false
    @Published var isVerified: Bool = false
    
    @Published var error: Bool = false
    @Published var errorMessage: String = ""
}

extension PasswordViewModel {
    func sendCode() {
        PhoneAuthProvider.provider().verifyPhoneNumber("+1" + self.phoneNumber, uiDelegate: nil) { verificationId, error in
            
            if error != nil {
                self.error.toggle()
                self.errorMessage = error?.localizedDescription ?? ""
                return
            }
        
            UserDefaults.standard.set(verificationId, forKey: "verificationId")
            self.verifying.toggle()
        }
    }
    
    func verifyCode(code: String) {
        self.loadingVerify.toggle()
        
        // Check if the code parameter is empty or nil
        guard !code.isEmpty else {
            self.loadingVerify.toggle()
            self.error.toggle()
            self.errorMessage = "Verification code is empty."
            return
        }
        
        let verificationId = UserDefaults.standard.string(forKey: "verificationId") ?? ""
        let credentials = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: code)
        
        self.loadingVerify.toggle()
        let user = Auth.auth().currentUser
        user?.updatePhoneNumber(credentials)

        // Now the display name is updated, call the completion handler with the username
        let userRef = db.collection("Users").document(user?.uid ?? "Sim User")
        userRef.updateData(["Phone Number": self.phoneNumber]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            }
        }
            
        self.verifying.toggle()
        self.isVerified.toggle()
    }
}
