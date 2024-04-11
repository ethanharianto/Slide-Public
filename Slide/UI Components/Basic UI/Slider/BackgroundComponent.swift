//  BackgroundComponent.swift
//  Slide
//  Created by Ethan Harianto on 8/14/23.

import SwiftUI

struct BackgroundComponent: View {

    @State private var hueRotation = false

    public init() { }

    public var body: some View {
        ZStack(alignment: .leading)  {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.primary)

            Text("Slide to RSVP")
                .font(.footnote)
                .bold()
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: true)) {
                hueRotation.toggle()
            }
        }
    }

}
