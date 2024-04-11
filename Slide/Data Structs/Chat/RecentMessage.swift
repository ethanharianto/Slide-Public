//  RecentMessage.swift
//  Slide
//  Created by Ethan Harianto on 8/5/23.

import SwiftUI
import Firebase

struct RecentMessage: Identifiable {
    var id: String { documentId }
    let documentId: String
    let text: String
    let fromId, toId: String
    let profileImageUrl: String
    let timestamp: Timestamp
    var isRead: Bool

    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.text = data["text"] as? String ?? ""
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.isRead = data["isRead"] as? Bool ?? false
    }
}
