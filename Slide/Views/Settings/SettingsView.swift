//
//  SettingsView.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import FirebaseAuth
import SwiftUI
import UIKit

struct SettingsView: View {
    @State private var clicks = [false, false, false, false, false, false, false, false]
    @Binding var selectedColorScheme: String
    let user = Auth.auth().currentUser
    @State private var updatedUsername: String = ""
    @State private var isShowingTutorial = false
    @StateObject var notificationPermission = NotificationPermission()
    @State private var isDeleteErrorVisible = false
    @State private var deleteErrorMessage = ""
    @State private var isPrivacyPolicyVisible = false

    
    var body: some View {
        List {
            // Username
            Group {
                Button {
                    withAnimation {
                        toggleClicks(count: 0)
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Username")
                                .foregroundColor(.primary)
                            Text(user?.displayName ?? "SimUser")
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(clicks[0] ? 90 : 0))
                    }
                }
                
                if clicks[0] {
                    updateUsernameView(updatedUsername: $updatedUsername, clicked: $clicks[0])
                }
            }
            
            // Email
            Group {
                Button {
                    withAnimation {
                        toggleClicks(count: 1)
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Email")
                                .foregroundColor(.primary)
                            Text(user?.email ?? "SimUser@stanford.edu")
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if !(user?.isEmailVerified ?? false) {
                            Button(action: {
                                // Add logic to resend email verification
                                Auth.auth().currentUser?.sendEmailVerification { error in
                                    if let error = error {
                                        print("Error sending verification email: \(error)")
                                    } else {
                                        print("Verification email sent.")
                                    }
                                }
                            }) {
                                Text("Resend")
                                    .foregroundColor(.red)
                            }
                        }
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(clicks[1] ? 90 : 0))
                    }
                }
                
                if clicks[1] {}
            }
            
            // Phone #
            Group {
                Button {
                    withAnimation {
                        toggleClicks(count: 2)
                    }
                } label: {
                    HStack {
                        VStack {
                            Text("Phone Number")
                                .foregroundColor(.primary)
                            if !(user?.phoneNumber ?? "").isEmpty {
                                Text(user?.phoneNumber ?? "")
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        if (user?.phoneNumber ?? "").isEmpty {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundColor(.red)
                        }
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(clicks[2] ? 90 : 0))
                    }
                }
                if clicks[2] {
                    if (user?.phoneNumber ?? "").isEmpty {
                        PhoneNumberView()
                    } else {
                        Text("You've already set your phone number.")
                    }
                }
            }
            
            // Password
            Group {
                Button {
                    withAnimation {
                        toggleClicks(count: 3)
                    }
                } label: {
                    HStack {
                        Text("Password")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(clicks[3] ? 90 : 0))
                    }
                }
                
                if clicks[3] {
                    PasswordView()
                }
            }
            
            // App Appearance
            //            Group {
            //                Button {
            //                    withAnimation {
            //                        toggleClicks(count: 4)
            //                    }
            //                } label: {
            //                    HStack {
            //                        Text("App Appearance")
            //                            .foregroundColor(.primary)
            //                        Spacer()
            //                        Image(systemName: "chevron.right")
            //                            .rotationEffect(.degrees(clicks[4] ? 90 : 0))
            //                    }
            //                }
            //
            //                if clicks[4] {
            //                    AppAppearanceView(selectedColorScheme: $selectedColorScheme)
            //                }
            //            }
            // Delete Account
            Group {
                Button {
                    withAnimation {
                        toggleClicks(count: 6)
                    }
                } label: {
                    HStack {
                        Text("Delete Account")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(clicks[6] ? 90 : 0))
                    }
                }
                
                if clicks[6] {
                    Button("Confirm Delete") {
                        deleteAccount()
                    }
                    .foregroundColor(.red)
                    .alert(isPresented: $isDeleteErrorVisible) {
                        Alert(title: Text("Error"), message: Text(deleteErrorMessage), dismissButton: .default(Text("OK")))
                    }
                }
            }
            
            // Sign Out
            Group {
                Button {
                    withAnimation {
                        toggleClicks(count: 5)
                    }
                } label: {
                    HStack {
                        Text("Sign Out")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(clicks[5] ? 90 : 0))
                    }
                }
                
                if clicks[5] {
                    SignOutView()
                }
                Button {
                    isShowingTutorial.toggle()
                } label: {
                    Text("Tutorial")
                }
                
                Group {
                    Button {
                        withAnimation {
                            toggleClicks(count: 7)
                        }
                    } label: {
                        HStack {
                            Text("Contact Us")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .rotationEffect(.degrees(clicks[7] ? 90 : 0))
                        }
                    }

                    if clicks[7] {
                        Button(action: {
                            if let url = URL(string: "mailto:hello@slidesocial.app") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("hello@slidesocial.app")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Button(action: {
                    if let url = URL(string: "https://slidesocial.app/privacy.html") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Privacy Policy")
                        .foregroundColor(.blue)
                }
                
                
            }
        }
        
        .onChange(of: selectedColorScheme) { value in
            UserDefaults.standard.set(value, forKey: "colorSchemePreference")
        }
        .onAppear {
            selectedColorScheme = UserDefaults.standard.string(forKey: "colorSchemePreference") ?? "dark"
        }
        
        .fullScreenCover(isPresented: $isShowingTutorial) {
            TutorialView(isShowingTutorial: $isShowingTutorial)
        }
    }
    
    func toggleClicks(count: Int) {
        for index in 0 ..< clicks.count {
            if index != count {
                clicks[index] = false
            }
        }
        clicks[count].toggle()
    }
    
    func deleteAccount() {
        guard let currentUserID = user?.uid else {
            return
        }
        
        // Events
        deleteEvents(for: currentUserID)
        
        // Posts
        
        // TODO: AS THE THIRD TODO REITERATES, deleteFriendDocuments MUST BE COMPLETED BEFORE deleteUserDocument Starts
        // Friendships and outgoings/incomings
        
        // TODO: Messages (sent and received?)
//        deleteMessages(for: currentUserID)
        // User and Username docs
        // TODO: deleteUsernameDocument has to COMPLETE before deleteUserDocument STARTS
        // TODO: U basically just need this function to not run until everything above has run
    }

//
//    func deleteMessages(for userID: String) {
//        print("fuck1")
//        let messageUserRef = db.collection("messages").document(userID)
//        messageUserRef.delete { error in
//            if let error = error {
//                print("Error deleting user: \(error)")
//            }
//        }
//
//        let messageRef = db.collection("messages")
//        messageRef.getDocuments { snapshot, _ in
//            print("fuck2")
//            for document in snapshot?.documents ?? [] {
//                print("fuck3")
//                document.reference.collection(userID).getDocuments { snapshot, _ in
//                    for document in snapshot?.documents ?? [] {
//                        print("fuck4")
//                        document.reference.delete()
//                    }
//                }
//            }
//        }
//    }
    
    func deletePosts(for userID: String) {
        let postsCollectionRef = db.collection("Posts")
        
        let query = postsCollectionRef.whereField("User", isEqualTo: userID)
        let group = DispatchGroup()
        group.enter()
        query.getDocuments { snapshot, error in
            if error != nil {
                return
            }

            for document in snapshot?.documents ?? [] {
                print("fook")
                let postID = document.documentID
                let postReference = db.collection("Posts").document(postID)
                postReference.delete { _ in
                }
            }
            group.leave()
        }
        group.notify(queue: .main) {
            deleteFriendDocuments(for: userID)
        }
    }

    func deleteEvents(for userID: String) {
        let eventsCollectionRef = db.collection("Events")
        let query = eventsCollectionRef.whereField("HostUID", isEqualTo: userID)
        let group = DispatchGroup()
        group.enter()
        query.getDocuments { snapshot, error in
            if error != nil {
                return
            }
            
            for document in snapshot?.documents ?? [] {
                print("shit")
                let eventID = document.documentID
                let eventReference = db.collection("Events").document(eventID)
                eventReference.delete { _ in }
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            deletePosts(for: userID)
        }
    }

    func deleteFriendDocuments(for userID: String) {
        let group = DispatchGroup()
        group.enter()
        let userDocument = db.collection("Users").document(userID)
        userDocument.getDocument { document, _ in
            if let document = document, document.exists {
                let incomingList = document.data()?["Incoming"] as? [String] ?? []
                let outgoingList = document.data()?["Outgoing"] as? [String] ?? []
                let friendList = document.data()?["Friends"] as? [String] ?? []
                for incoming in incomingList {
                    let incomingDocument = db.collection("User").document(incoming)
                    incomingDocument.getDocument { incomingDoc, _ in
                        if let incomingDoc = incomingDoc, incomingDoc.exists {
                            var incomingList = incomingDoc.data()?["Incoming"] as? [String] ?? []
                            incomingList.removeAll { $0 == userID }
                            incomingDocument.updateData(["Incoming": incomingList]) { _ in }
                        }
                    }
                }
                for outgoing in outgoingList {
                    let outgoingDocument = db.collection("Users").document(outgoing)
                    outgoingDocument.getDocument { outgoingDoc, _ in
                        if let outgoingDoc = outgoingDoc, outgoingDoc.exists {
                            var outgoingList = outgoingDoc.data()?["Outgoing"] as? [String] ?? []
                            outgoingList.removeAll { $0 == userID }
                            outgoingDocument.updateData(["Outgoing": outgoingList]) { _ in }
                        }
                    }
                }
                for friend in friendList {
                    let friendDocument = db.collection("Users").document(friend)
                    friendDocument.getDocument { friendDoc, _ in
                        if let friendDoc = friendDoc, friendDoc.exists {
                            var friendList = friendDoc.data()?["Friends"] as? [String] ?? []
                            friendList.removeAll { $0 == userID }
                            friendDocument.updateData(["Friends": friendList]) { _ in }
                        }
                    }
                }
            }
            group.leave()
        }
        group.notify(queue: .main) {
            deleteUsernameDocument(for: userID)
        }
    }

    func deleteMessages(for userID: String) {}
    
    func deleteUsernameDocument(for userID: String) {
        let userDocument = db.collection("Users").document(userID)
        userDocument.getDocument { document, _ in
            if let document = document, document.exists {
                if let username = document.data()?["Username"] as? String {
                    let usernameDocumentRef = db.collection("Usernames").document(username)
                    usernameDocumentRef.delete { error in
                        if error == nil {
                            deleteUserDocument(for: userID)
                        }
                    }
                }
            }
        }
    }

    func deleteUserDocument(for userID: String) {
        let userDocument = db.collection("Users").document(userID)
        userDocument.delete { error in
            if error == nil {
                Auth.auth().currentUser?.delete { error in
                    if let error = error {
                        print("Error deleting user: \(error)")
                        deleteErrorMessage = error.localizedDescription
                        isDeleteErrorVisible.toggle()
                    } else {
                        print("User account deleted successfully.")
                        // Add any additional logic if you wish to navigate the user away, etc.
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(selectedColorScheme: .constant("dark"))
    }
}
