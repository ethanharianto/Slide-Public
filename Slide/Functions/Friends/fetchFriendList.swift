//
//  fetchFriendList.swift
//  Slide
//
//  Created by Thomas on 9/13/23.
//

import Foundation
import Firebase

 func fetchFriendListAndReports(completion: @escaping ([String]?, [String]?, Error?) -> Void) {
    let user = Auth.auth().currentUser
    guard let currentUserID = user?.uid else {
        completion(nil, nil, NSError(domain: "YourAppErrorDomain", code: 401, userInfo: ["message": "User not authenticated."]))
        return
    }

    var friendList: [String] = []
    var highlightReportList: [String] = []

    let userDocumentRef = db.collection("Users").document(currentUserID)
    let group = DispatchGroup()
    
    group.enter()
    userDocumentRef.getDocument(completion: { d2, _ in
        if let d2 = d2, d2.exists {
            if let tempFriendsArray = d2.data()?["Friends"] as? [String] {
                friendList = tempFriendsArray
            }
            if let tempHighlightReportArray = d2.data()?["highlightsReport"] as? [String] {
                highlightReportList = tempHighlightReportArray
            }
        }
        group.leave()
    })
    
    group.notify(queue: .main) {
        completion(friendList, highlightReportList, nil)
    }

}
