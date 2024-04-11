//  ContactStruct.swift
//  Slide
//  Created by Ethan Harianto on 7/12/23.

import Foundation
import Contacts

struct ContactInfo: Identifiable {
    var id = UUID()
    var firstName: String
    var lastName: String
    var phoneNumber: CNPhoneNumber?
}
