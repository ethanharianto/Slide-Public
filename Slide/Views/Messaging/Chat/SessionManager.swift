//
//  SessionManager.swift
//  ChatFirestoreExample
//
//  Created by Alisa Mylnikova on 13.06.2023.
//

import Foundation
import ExyteChat
import UIKit

let hasCurrentSessionKey = "hasCurrentSession"
let currentUserKey = "currentUser"

class SessionManager {

    static let shared = SessionManager()

    static var currentUserId: String {
        shared.currentUser?.userID ?? ""
    }

    static var currentUser: UserData? {
        shared.currentUser
    }

    var deviceId: String {
        UIDevice.current.identifierForVendor?.uuidString ?? ""
    }

    @Published private var currentUser: UserData?

    func storeUser(_ user: UserData) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            UserDefaults.standard.set(encoded, forKey: currentUserKey)
        }
        UserDefaults.standard.set(true, forKey: hasCurrentSessionKey)
        currentUser = user
    }

    func loadUser() {
        if let data = UserDefaults.standard.data(forKey: "currentUser") {
            currentUser = try? JSONDecoder().decode(UserData.self, from: data)
        }
    }

    func logout() {
        currentUser = nil
        UserDefaults.standard.set(false, forKey: hasCurrentSessionKey)
        UserDefaults.standard.removeObject(forKey: currentUserKey)
    }
}
