//
//  AccountCreationBottom.swift
//  Slide
//
//  Created by Ethan Harianto on 7/22/23.
//

import Foundation
import SwiftUI

struct AccountCreationBottom: View {
    let text: String
    let buttonText: String
    @Binding var logIn: Bool
    @Binding var privacyAcknowledgment: Bool
    
    var body: some View {
        HStack {
            Text(text)
                .foregroundColor(.gray)
            Button(buttonText) {
                withAnimation {
                    logIn.toggle()
                }
            }
            .foregroundColor(.primary)
            .fontWeight(.bold)
        }

        GoogleButton(privacyAcknowledgement: $privacyAcknowledgment, registered: false)
    }
}
