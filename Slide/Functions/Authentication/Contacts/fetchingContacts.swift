//
//  FetchingContacts.swift
//  Slide
//
//  Created by Ethan Harianto on 7/12/23.
//

import Foundation
import Contacts

func fetchingContacts() -> [ContactInfo] {
    var contacts = [ContactInfo]()
    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
    let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
    do {
        try CNContactStore().enumerateContacts(with: request, usingBlock: { contact, _ in
            contacts.append(ContactInfo(firstName: contact.givenName, lastName: contact.familyName, phoneNumber: contact.phoneNumbers.first?.value))
        })
    } catch {
        print("Failed", error)
    }
    contacts = contacts.sorted {
        $0.firstName < $1.firstName
    }
    print(contacts)
    return contacts
}
