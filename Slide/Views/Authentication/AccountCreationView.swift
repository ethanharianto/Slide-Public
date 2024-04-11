//  AccountCreationView.swift
//  Slide
//  Created by Ethan Harianto on 7/22/23.

import SwiftUI

struct AccountCreationView: View {
    /* the logIn variable here is passed as the binding variable into the LogIn and Register views. This is done so that the AccountCreationBottom struct used in both views are able to toggle the logIn variable despite being separated by two layers. This then allows us to use a transition rather than the animation-less navigation link. */
    @State private var logIn = true
    @Binding var userSignedUp: Bool


    var body: some View {
        VStack {
            if logIn {
                LogIn(logIn: $logIn)
                    // comes in from the left
                    .transition(.move(edge: .leading))
                    .onAppear {
                        userSignedUp = false
                    }
            } else {
                Register(logIn: $logIn)
                    // comes in from the right
                    .transition(.move(edge: .trailing))
                    .onAppear {
                        userSignedUp = true
                    }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}
