//
//  ProgressIndicator.swift
//  Slide
//
//  Created by Ethan Harianto on 7/22/23.
//

import SwiftUI

struct ProgressIndicator: View {
    let numDone: Int
    let totalSteps: Int = 6 // The total number of steps in your registration process
    @State private var isAnimating = false

    var body: some View {
        VStack {
            HStack {
                ForEach(1 ... totalSteps, id: \.self) { index in
                    if index < numDone {
                        Capsule()
                            .foregroundColor(.cyan)
                    } else if index == numDone {
                        LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .leading, endPoint: .trailing)
                            .mask(Capsule())
                            .foregroundColor(.cyan)
                            .scaleEffect(isAnimating ? 1.0 : 0.001)
                            .animation(.spring(), value: isAnimating)
                    } else {
                        Capsule()
                            .foregroundColor(.gray.opacity(0.8))
                    }
                }
            }
            .frame(width: 0.95 * UIScreen.main.bounds.width, height: 8)
            .onAppear {
                isAnimating = true
            }
            .padding(.top, 10)
            Spacer()
        }
    }
}


struct ProgressIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ProgressIndicator(numDone: 3)
    }
}
