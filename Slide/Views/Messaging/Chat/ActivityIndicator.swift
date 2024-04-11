//
//  ActivityIndicator.swift
//  Slide
//
//  Created by Ethan Harianto on 9/24/23.
//

import SwiftUI
import ActivityIndicatorView

struct ActivityIndicator: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .frame(width: 100, height: 100)
                .cornerRadius(8)
            
            ActivityIndicatorView(isVisible: .constant(true), type: .flickeringDots())
                .foregroundColor(.gray)
                .frame(width: 50, height: 50)
        }
    }
}
