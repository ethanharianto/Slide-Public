//  LogIn.swift
//  Slide
//  Created by Ethan Harianto on 12/16/22.

import Firebase
import FirebaseFirestore
import SwiftUI

struct LogIn: View {
    // email variable is linked to the username text field
    @State var email = ""
    // password variable is linked to the password text field
    @State var password = ""
    // error message only pops up when there is an error during log-in
    @State var errorMessage = ""
    // variable passed in by a parent view and passed to the AccountCreationBottom
    @Binding var logIn: Bool
    
    var body: some View {
        VStack {
            VStack {
                Image("logo")
                    
                Text(errorMessage)
                    .foregroundColor(.red)
                        
                VStack(alignment: .leading, spacing: 15) {
                    Section("Username") {
                        TextField("Enter your email/username", text: $email)
                            .checkMarkTextField()
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .bubbleStyle(color: .primary)
                            .onChange(of: email) { _ in
                                isGoogleUser(email: email) { isGoogleUser, error in
                                    if let error = error {
                                        errorMessage = error.localizedDescription
                                    } else {
                                        if isGoogleUser {
                                            errorMessage = "This email was registered using Google. Please use the Google button below to log in."
                                        }
                                    }
                                }
                            }
                    }

                    Section("Password") {
                        PasswordField(password: $password, text: "Enter your password")
                            .checkMarkTextField()
                            .bubbleStyle(color: .primary)
                    }
                }
                                    
                // sign in button with rounded cyan border
                Button {
                    login(email: email, password: password) { error in
                        errorMessage = error
                    }
                } label: {
                    Text("Log In").filledBubble()
                }
            }
            .padding()
            AccountCreationBottom(text: "Don't have an account?", buttonText: "Sign Up", logIn: $logIn, privacyAcknowledgment: .constant(true))
        }
    }
}

struct LogIn_Previews: PreviewProvider {
    static var previews: some View {
        LogIn(logIn: .constant(true))
    }
}
