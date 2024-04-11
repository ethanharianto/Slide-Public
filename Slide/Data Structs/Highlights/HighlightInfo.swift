//  HighlightInfo.swift
//  Slide
//  Created by Ethan Harianto on 7/20/23.

import Foundation

struct HighlightInfo: Identifiable, Equatable {
    static func == (lhs: HighlightInfo, rhs: HighlightInfo) -> Bool {
        return lhs.imageName == rhs.imageName
    }

    var uid: String
    var id = UUID()
    var postID: String
    var imageName: String
    var profileImageName: String
    var username: String
    var highlightTitle: String
    var likedUsers: [String] // List of user document ids that liked the post
    var postTime: Date
}
