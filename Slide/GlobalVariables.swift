//
//  GlobalVariables.swift
//  Slide
//
//  Created by Ethan Harianto on 7/12/23.
//

import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import SwiftUI

/*
 Several global variables to keep track of backend operations
 storage for firebase image storage
 db for firebase firestore
 hypestEventScore for calculating the most popular event in the last week
 */
let storage = Storage.storage()
let storageRef = storage.reference()
let db = Firestore.firestore()
var hypestEventScore = 0
