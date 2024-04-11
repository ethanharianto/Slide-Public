//  CustomSegmentedView.swift
//  Slide
//  Created by Ethan Harianto on 8/12/23.

import SwiftUI

struct CustomSegmentedView: View {
    var totalTabs: Int
    @Binding var selectedTab: Int
    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 4) {
                ForEach(0 ..< totalTabs, id: \.self) { index in
                    Capsule()
                        .foregroundColor(selectedTab == index ? .accentColor : .gray.opacity(0.5))
                        .frame(width: selectedTab == index ? 24 : 6, height: 6)
                }
            }
        }
    }
}
