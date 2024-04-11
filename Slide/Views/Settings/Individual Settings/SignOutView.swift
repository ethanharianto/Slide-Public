//
//  SignOutView.swift
//  Slide
//
//  Created by Ethan Harianto on 7/28/23.
//

import SwiftUI

struct SignOutView: View {
    var body: some View {
        Button {
            signOut()
        } label: {
            Text("Sign Out")
                .filledBubble()
        }
    }
}

struct SignOutView_Previews: PreviewProvider {
    static var previews: some View {
        SignOutView()
    }
}
