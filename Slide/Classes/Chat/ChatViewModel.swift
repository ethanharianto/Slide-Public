// ChatViewModel.swift
// Slide
// Created by Ethan Harianto on 8/5/23.

import Firebase
import Foundation
import SwiftUI
class ChatViewModel: ObservableObject {
    let chatUser: ChatUser?
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var chatMessages = [ChatMessage]()
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        fetchMessages()
    }

    private func fetchMessages() {
        guard let sender = Auth.auth().currentUser?.uid else {
            return
        }
        guard let recipient = chatUser?.uid else { return }
        db.collection("messages")
            .document(sender)
            .collection(recipient)
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for messages \(error)"
                    print(error)
                    return
                }
                querySnapshot?.documentChanges.forEach { change in
                    if change.type == .added {
                        let data = change.document.data()
                        self.chatMessages.append(.init(documentId: change.document.documentID, data: data))
                    }
                }
                DispatchQueue.main.async {
                    self.count += 1
                }
            }
    }

    func handleSend() {
        guard let sender = Auth.auth().currentUser?.uid else {
            return
        }
        guard let recipient = chatUser?.uid else { return }
        let document = db.collection("messages")
            .document(sender)
            .collection(recipient)
            .document()
        let messageData = ["sender": sender, "recipient": recipient, "text": chatText, "timestamp": Timestamp()] as [String: Any]
        document.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save message in Firestore: \(error)"
                return
            }
            self.persistRecentMessage()
            self.persistRecentMessageForRecipient()
            self.chatText = ""
            self.count += 1
        }
        let recipientDocument = db.collection("messages")
            .document(recipient)
            .collection(sender)
            .document()
        recipientDocument.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save message in Firestore: \(error)"
                return
            }
        }
    }

    private func persistRecentMessage() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        guard let toId = chatUser?.uid else { return }
        let document = db.collection("recent_messages")
            .document(uid)
            .collection("messages")
            .document(toId)
        let data = [
            "timestamp": Timestamp(),
            "text": chatText,
            "fromId": uid,
            "toId": toId,
            "profileImageUrl": chatUser?.profileImageUrl ?? "",
            "isRead": true
        ] as [String: Any]
        document.setData(data) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent message: \(error)"
                return
            }
        }
    }

    private func persistRecentMessageForRecipient() {
        guard let sender = Auth.auth().currentUser?.uid else {
            return
        }
        guard let recipient = chatUser?.uid else {
            return
        }
        let document = db.collection("recent_messages")
            .document(recipient)
            .collection("messages")
            .document(sender)
        let data = [
            "timestamp": Timestamp(),
            "text": chatText,
            "fromId": sender,
            "toId": recipient,
            "profileImageUrl": chatUser?.profileImageUrl ?? "",
            "isRead": false
        ] as [String: Any]
        document.setData(data) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent message for recipient: \(error)"
                return
            }
        }
    }

    @Published var count = 0
}
