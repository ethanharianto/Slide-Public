//  MainMessagesViewModel.swift
//  Slide
//  Created by Ethan Harianto on 8/5/23.

import Firebase
import Foundation

class MainMessagesViewModel: ObservableObject {
    @Published var chatUser: ChatUser?
    @Published var recentMessages = [String: [RecentMessage]]() // Dictionary to store messages
    var snapshotChangedHandler: ((RecentMessage) -> Void)?
    var initial = true

    init() {
        fetchRecentMessages()
    }

    private func fetchRecentMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        db.collection("recent_messages")
            .document(uid)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print(error)
                    return
                }

                querySnapshot?.documentChanges.forEach { change in
                    let docId = change.document.documentID
                    let data = change.document.data()
                    let message = RecentMessage(documentId: docId, data: data)

                    let otherUserId = message.fromId == uid ? message.toId : message.fromId

                    if self.recentMessages[otherUserId] == nil {
                        self.recentMessages[otherUserId] = [message]
                    } else {
                        self.recentMessages[otherUserId]?.append(message)
                    }

                    if !self.initial {
                        self.snapshotChangedHandler?(message)
                    }
                }
                if self.initial {
                    self.initial = false
                }
            }
    }

    func hideMessage(_ message: RecentMessage) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let otherUserId = message.fromId == uid ? message.toId : message.fromId
        db.collection("recent_messages")
            .document(uid)
            .collection("messages")
            .document(otherUserId)
            .delete{ [self] error in
                if error != nil {
                    // Handle the error
                } else {
                    recentMessages[otherUserId]?.removeAll()
                    objectWillChange.send()
                }
            }
    }
}
