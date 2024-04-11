//
//  SlidesView.swift
//  Slide
//
//  Created by Thomas on 8/21/23.
//

import SwiftUI

struct SlidesView: View {
    var nonFriendsList: [String]
    var friendsList: [String]
    
    var body: some View {
        VStack {
            ForEach(friendsList, id: \.self) { attendee in
                HStack {
                    Text(attendee)
                    Text("Friend")
                }
            }
            ForEach(nonFriendsList, id: \.self) { attendee in
                HStack{
                    Text(attendee)
                    Text("Not Friend")
                }
            }
        }
    }
}
