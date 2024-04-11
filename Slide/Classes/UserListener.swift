//
//  UserListener.swift
//  Slide
//
//  Created by Ethan Harianto on 2/10/23.
//

import FirebaseAuth
import Foundation
import SwiftUI

class UserListener: ObservableObject {
    @Published var user: User?

    init() {
        listenForAuthChanges()
    }

    private func listenForAuthChanges() {
        Auth.auth().addStateDidChangeListener { _, user in
            if let user = user {
                self.user = user
            } else {
                self.user = nil
            }
        }
    }
}
