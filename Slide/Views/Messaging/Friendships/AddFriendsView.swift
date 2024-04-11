// UserSearchAndFriendView.swift
// Slide
// Created by Thomas on 6/29/23.

import Combine
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

/* Test Data:
 UserData(userID: "mwahah", username: "baesuzy", photoURL: "https://m.media-amazon.com/images/M/MV5BZWQ5YTFhZDAtMTg3Yi00NzIzLWIyY2EtNDQ2YWNjOWJkZWQxXkEyXkFqcGdeQXVyMjQ2OTU4Mjg@._V1_.jpg", added: false), UserData(userID: "mwahahah", username: "tomholland", photoURL: "https://static.foxnews.com/foxnews.com/content/uploads/2023/07/GettyImages-1495234870.jpg", added: false)
 */

struct AddFriendsView: View {
    let user = Auth.auth().currentUser
    @State private var searchQuery = ""
    @State private var searchResults: [UserData] = []
    @State private var pendingFriendRequests: [UserData] = []
    @State private var friendList: [UserData] = []
    @State private var recommendations: Set<UserData> = []
    @State private var refreshPending = false
    @State private var refreshSearch = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button { self.presentationMode.wrappedValue.dismiss() } label: {
                    Image(systemName: "chevron.left")
                }
                .padding(.leading)
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search for users", text: $searchQuery)
                        .onChange(of: searchQuery) { _ in
                            searchUsers()
                        }
                }
                .checkMarkTextField()
                .bubbleStyle(color: .primary)
                .padding()
            }
            .padding()
            .padding(.bottom, -10)

            if searchQuery.isEmpty {
                if !pendingFriendRequests.isEmpty {
                    List {
                        Section {
                            PendingRequests(pendingFriendRequests: $pendingFriendRequests, refreshPending: $refreshPending)
                        } header: {
                            Text("Pending Requests")
                                .font(.caption)
                        }
                    }
                } else if !recommendations.isEmpty {
                    List {
                        Section {
                            ContactRecommendations(contacts: $recommendations)
                        } header: {
                            Text("Contacts on Slide")
                                .font(.caption)
                        }
                    }
                } else {
                    Spacer()
                }
            } else {
                List {
                    if !searchResults.isEmpty {
                        Section {
                            UserSearchResults(searchResults: $searchResults)
                        } header: {
                            Text("Users")
                                .font(.caption)
                        }
                    }
                    if !friendList.isEmpty {
                        Section {
                            FriendsList(friendsList: $friendList)
                        } header: {
                            Text("Friends")
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .onReceive(Just(refreshPending)) { _ in
            fetchPendingFriendRequests()
            refreshPending = false
        }
        .onAppear {
            fetchPendingFriendRequests()
            fetchRecommendations()
        }
        .refreshable {
            fetchPendingFriendRequests()
            fetchRecommendations()
        }
        .navigationBarBackButtonHidden(true)
    }

    func fetchRecommendations() {
        guard let currentUserID = user?.uid else {
            return
        }
        let userDocumentRef = db.collection("Users").document(currentUserID)
        var recommendations: Set<UserData> = []

        let group = DispatchGroup() // Create a DispatchGroup

        // Step 1: Access the User document using the given document ID
        userDocumentRef.getDocument { document, _ in
            if let document = document, document.exists {
                let contacts = document.data()?["Contacts"] as? [String: Any] ?? [:]
                for number in contacts.keys {
                    group.enter() // Enter the DispatchGroup before starting each fetchUserDetails call
                    let query = db.collection("Users").whereField("Phone Number", isGreaterThanOrEqualTo: number)
                    query.getDocuments { querySnapshot, error in
                        if let error = error {
                            print(error)
                            group.leave() // Make sure to leave the DispatchGroup in case of an error
                            return
                        }

                        if let document = querySnapshot?.documents.first {
                            fetchUserDetails(userID: document.documentID) { userDetails in
                                if let userDetails = userDetails {
                                    // Handle userDetails if it's not nil
                                    if !userDetails.added! && userDetails.userID != user!.uid {
                                        recommendations.insert(userDetails)
                                    }
                                }
                                group.leave() // Leave the DispatchGroup after the fetchUserDetails call is completed
                            }
                        } else {
                            // If no document is found for this number, still leave the DispatchGroup
                            group.leave()
                        }
                    }
                }

                group.notify(queue: .main) {
                    // This closure will be called when all fetchUserDetails calls are completed
                    self.recommendations = recommendations
                    print(self.recommendations)
                }
            }
        }
    }

    func fetchPendingFriendRequests() {
        guard let currentUserID = user?.uid else {
            return
        }
        let userDocumentRef = db.collection("Users").document(currentUserID)
        var pendingRequests: [UserData] = []

        let group = DispatchGroup() // Create a DispatchGroup

        // Step 1: Access the User document using the given document ID
        userDocumentRef.getDocument { document, _ in
            if let document = document, document.exists {
                let incomingList = document.data()?["Incoming"] as? [String] ?? []
                for otherID in incomingList {
                    group.enter() // Enter the DispatchGroup before starting each fetchUserDetails call
                    fetchUserDetails(userID: otherID) { userDetails in
                        if let userDetails = userDetails {
                            // Handle userDetails if it's not nil
                            pendingRequests.append(userDetails)
                        }
                        group.leave() // Leave the DispatchGroup after the fetchUserDetails call is completed
                    }
                }

                group.notify(queue: .main) {
                    // This closure will be called when all fetchUserDetails calls are completed
                    self.pendingFriendRequests = pendingRequests
                }
            }
        }
    }

    func searchUsers() {
        searchResults.removeAll()
        friendList.removeAll()
        searchUsersByUsername(username: searchQuery.lowercased()) { users, friends in
            DispatchQueue.main.async {
                self.searchResults = users
                self.friendList = friends
            }
        }
    }
}

struct UserSearchAndFriendView_Previews: PreviewProvider {
    static var previews: some View {
        AddFriendsView()
    }
}
