//  UITabBar.swift
//  Slide
//  Created by Ethan Harianto on 8/2/23.

import UIKit

extension UITabBar {
    static func customizeAppearance() {
        /* When called, this code changes the tab bar so that unselected items are white and the bar is opaque. */
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().barTintColor = UIColor.clear
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
    }
}
