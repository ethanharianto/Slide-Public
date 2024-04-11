//
//  PasswordField.swift
//  Slide
//
//  Created by Ethan Harianto on 7/14/23.
//

import Foundation
import SwiftUI

struct PasswordField: View {
    @State private var isSecureTextEntry = true
    @State private var showPassword = false
    @FocusState private var isFocused: Bool
    @Binding var password: String
    let text: String
    
    var body: some View {
        HStack {
            if isSecureTextEntry {
                SecureField(text, text: $password)
            } else {
                TextField(text, text: $password)
            }
            
            Button(action: {
                showPassword.toggle()
                isSecureTextEntry.toggle()
            }) {
                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.primary)
                    .padding(.trailing, isFocused ? 30 : 0)
                    .animation(.default, value: isFocused)
            }
        }
        .focused($isFocused)
    }
}
