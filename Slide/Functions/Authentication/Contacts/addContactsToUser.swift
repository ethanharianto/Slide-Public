//
//  addContactsToUser.swift
//  Slide
//
//  Created by Ethan Harianto on 7/21/23.
//

import FirebaseAuth
import Foundation

func addContactsToUser(contactList: [ContactInfo]) {
    guard let user = Auth.auth().currentUser else {
        return
    }

    let uid = user.uid

    let usersRef = db.collection("Users").document(uid)
    var contactIdList = [String: [[String: String]]]() // Dictionary with phone number as key and array of dictionaries as value

    for contact in contactList {
        let firstName = contact.firstName
        let lastName = contact.lastName
        let number = contact.phoneNumber?.stringValue ?? "No Number"

        // Check if the array exists for the given number, if not create it
        if contactIdList[number] == nil {
            contactIdList[number] = [[String: String]]()
        }

        // Append the dictionary to the array under the corresponding number
        contactIdList[number]?.append(["firstName": firstName, "lastName": lastName])
    }

    usersRef.getDocument { _, error in
        if let error = error {
            print("Error fetching document: \(error)")
            return
        }

        let userData: [String: Any] = [
            "Contacts": contactIdList,
        ]
        usersRef.updateData(userData) { error in
            if let error = error {
                print("Error adding document: \(error)")
            }
        }
    }
}
