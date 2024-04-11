//  BaseButtonStyle.swift
//  Slide
//  Created by Ethan Harianto on 8/14/23.

import SwiftUI

struct BaseButtonStyle: ButtonStyle {

    public init() { }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.default, value: configuration.isPressed)
    }

}
