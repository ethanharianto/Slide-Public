//
//  updateUsernameView.swift
//  Slide
//
//  Created by Ethan Harianto on 7/28/23.
//

import SwiftUI
import FirebaseAuth

struct updateUsernameView: View {
    @Binding var updatedUsername: String
    @Binding var clicked: Bool
    let user = Auth.auth().currentUser
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Your username is how people find you on Slide.")
                .foregroundColor(.secondary)
            TextField(user?.displayName ?? "SimUser", text: $updatedUsername)
                .checkMarkTextField()
                .bubbleStyle(color: .primary)
            Button {
                if !updatedUsername.isEmpty && !updatedUsername.contains(" ") {
                    updateUsername(username: updatedUsername) { username in
                        updatedUsername = username
                        clicked = false
                    }
                }
            } label: {
                Text("Change Username").filledBubble()
            }
        }
        .padding()
        .transition(.opacity)
    }
}

struct updateUsernameView_Previews: PreviewProvider {
    static var previews: some View {
        updateUsernameView(updatedUsername: .constant(""), clicked: .constant(true))
    }
}
