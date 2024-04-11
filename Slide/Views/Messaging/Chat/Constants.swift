//
//  Constants.swift
//  ChatFirestoreExample
//
//  Created by Alisa Mylnikova on 10.07.2023.
//

import SwiftUI
import ExyteChat
import ExyteMediaPicker

struct Collection {
    static let users = "users"
    static let conversations = "conversations"
    static let messages = "messages"
}

extension String {
    static var avatarPlaceholder = "avatarPlaceholder"
    static var placeholderAvatar = "placeholderAvatar"
    static var bob = "bob"
    static var checkSelected = "checkSelected"
    static var checkUnselected = "checkUnselected"
    static var groupChat = "groupChat"
    static var imagePlaceholder = "imagePlaceholder"
    static var logo = "logo"
    static var navigateBack = "navigateBack"
    static var newChat = "newChat"
    static var photoIcon = "photoIcon"
    static var searchCancel = "searchCancel"
    static var searchIcon = "searchIcon"
    static var steve = "steve"
    static var tim = "tim"
}

var dataStorage = DataStorageManager.shared

public typealias Message = ExyteChat.Message
public typealias Recording = ExyteChat.Recording
public typealias Media = ExyteMediaPicker.Media
