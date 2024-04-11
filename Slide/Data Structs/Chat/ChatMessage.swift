//  ChatMessage.swift
//  Slide
//  Created by Ethan Harianto on 8/5/23.

import Foundation
import SwiftUI

struct ChatMessage: Identifiable {
    var id: String { documentId }
    let documentId: String
    let sender, recipient, text: String

    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.sender = data["sender"] as? String ?? ""
        self.recipient = data["recipient"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
    }
}
