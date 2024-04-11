//
//  Contacts Permission.swift
//  Slide
//
//  Created by Ethan Harianto on 7/21/23.
//

import Foundation
import Contacts

class ContactsPermission: NSObject, ObservableObject {
    @Published var isContactsPermission: Bool = false
    @Published var authorizationStatus: CNAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        self.authorizationStatus = checkContactsPermission()
    }

    func checkContactsPermission() -> CNAuthorizationStatus {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        return status
    }
    
    func requestContactsPermission() {
        CNContactStore().requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                self.handleContactsPermissionStatus(granted ? .authorized : .denied)
            }
        }
    }

    private func handleContactsPermissionStatus(_ status: CNAuthorizationStatus) {
        switch status {
        case .authorized:
            isContactsPermission = true
        case .denied, .restricted:
            isContactsPermission = false
        case .notDetermined:
            isContactsPermission = false
        @unknown default:
            isContactsPermission = false
        }
    }
}

