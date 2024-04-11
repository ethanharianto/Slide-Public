//
//  SearchField.swift
//  Slide
//
//  Created by Ethan Harianto on 9/24/23.
//

import SwiftUI

struct SearchField: View {

    @Binding var text: String

    var body: some View {
        ZStack {
            Color.primary
                .cornerRadius(8)
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search", text: $text)
                if !text.isEmpty {
                    Image(systemName: "xmark")
                        .onTapGesture {
                            text = ""
                        }
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 36)
    }
}
