//
//  CustomTextField.swift
//  ChatFirestoreExample
//
//  Created by Alisa Mylnikova on 11.07.2023.
//

import SwiftUI

struct CustomTextField: View {

    var placeholder: String
    @Binding var text: String

    @FocusState private var isFocused: Bool

    var body: some View {
        TextField(placeholder, text: $text)
            .focused($isFocused)
            .foregroundColor(.black)
            .tint(.blue)
            .padding(10)
            .background(Color.darkGray.cornerRadius(10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isFocused ? Color.blue : Color.gray, lineWidth: 1)
            )
    }
}

struct BlueButton: ButtonStyle {

    @Environment(\.isEnabled) private var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(17, .white, .medium)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .foregroundColor(isEnabled ? .blue : .gray)
            }
    }
}

