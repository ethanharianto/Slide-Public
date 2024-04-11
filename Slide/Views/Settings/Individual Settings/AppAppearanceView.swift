//
//  AppAppearanceView.swift
//  Slide
//
//  Created by Ethan Harianto on 7/28/23.
//

import SwiftUI

struct AppAppearanceView: View {
    @Binding var selectedColorScheme: String
    var body: some View {
        Picker("Color Scheme", selection: $selectedColorScheme) {
            Text("Light").tag("light")
            Text("Dark").tag("dark")
        }
        .pickerStyle(.segmented)
    }
}

struct AppAppearanceView_Previews: PreviewProvider {
    static var previews: some View {
        AppAppearanceView(selectedColorScheme: .constant("dark"))
    }
}
