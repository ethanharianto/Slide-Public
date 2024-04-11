//
//  GoogleSignInView.swift
//  Slide
//
//  Created by Ethan Harianto on 7/12/23.
//

import Firebase
import GoogleSignIn
import SwiftUI

struct GoogleButton: View {
    @Binding var privacyAcknowledgement: Bool
    @State private var errorMessage: String = ""
    let registered: Bool

    var body: some View {
        VStack {
            // Sign-In with Google Button
            Button(action: {
                if privacyAcknowledgement {
                    googleSignIn(registered: false) { error in
                        // Handle the completion result
                        if !error.isEmpty {
                            self.errorMessage = error
                        }
                    }
                } else {
                    self.errorMessage = "Please acknowledge the privacy policy."
                }
            }) {
                Image("google_logo")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            .bubbleStyle(color: .primary)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top)
            }
        }
    }
}

struct GoogleButton_Previews: PreviewProvider {
    static var previews: some View {
        GoogleButton(privacyAcknowledgement: .constant(false), registered: false)
    }
}
