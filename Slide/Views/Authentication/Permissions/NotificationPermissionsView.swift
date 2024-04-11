//
//  NotificationPermissionsView.swift
//  Slide
//
//  Created by Ethan Harianto on 7/22/23.
//

import SwiftUI

struct NotificationPermissionsView: View {
    @ObservedObject var notificationsPermission = NotificationPermission()
    
    var body: some View {
        ZStack {
            ProgressIndicator(numDone: 5)
            VStack(alignment: .center) {
                Image("notification_permission")
                    .resizable()
                    .frame(width: 160, height: 160)
                
                Text("Allow notifications?")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                Text("We use notifications to keep you updated on your latest events and messages")
                    .frame(width: 350)
                    .multilineTextAlignment(.center)
                    
                Button {
                    notificationsPermission.requestNotificationPermission()
                } label: {
                    Text("Okay")
                        .filledBubble()
                }
                .padding()
            }
        }
    }
}

struct NotificationPermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPermissionsView()
    }
}
