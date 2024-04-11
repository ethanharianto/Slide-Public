//
//  ContactsPermissionsView.swift
//  Slide
//
//  Created by Ethan Harianto on 7/21/23.
//

import SwiftUI

struct ContactsPermissionsView: View {
    @ObservedObject var contactsPermission = ContactsPermission()
    
    var body: some View {
        ZStack {
            ProgressIndicator(numDone: 3)
            VStack(alignment: .center) {
                Image("contacts_permission")
                    .resizable()
                    .frame(width: 160, height: 160)
                
                Text("Allow contacts access?")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                Text("We use your contact information to help us connect you with your friends")
                    .frame(width: 350)
                    .multilineTextAlignment(.center)
                    
                Button {
                    contactsPermission.requestContactsPermission()
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
                        addContactsToUser(contactList: getContacts(contactsPermission.isContactsPermission))
                    }
                    
                } label: {
                    Text("Okay")
                        .filledBubble()
                }
                
                .padding()
            }
        }
    }
}

struct ContactsPermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsPermissionsView()
    }
}
