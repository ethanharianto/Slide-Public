//
//  accumulateContacts.swift
//  Slide
//
//  Created by Ethan Harianto on 7/14/23.
//

import Foundation
import SwiftUI

func getContacts(_ contactsGranted: Bool) -> [ContactInfo] {
    
    var contactList = [ContactInfo]()
    if contactsGranted {
        let fetchedContacts = fetchingContacts()
        contactList.append(contentsOf: fetchedContacts)
    } else {
        print("Error 130")
    }
    return contactList
}
