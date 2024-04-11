//  ProfileHighlightsView.swift
//  Slide
//  Created by Ethan Harianto on 7/26/23.

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct ProfileHighlightsView: View {
    let user = Auth.auth().currentUser
    @ObservedObject var highlightHolder = ProfileInfo()
    @State private var post: HighlightInfo? = nil
    @State private var selectedUser: UserData? = nil
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(highlightHolder.highlights) { highlight in
                    SmallHighlightCard(highlight: highlight)
                        .onTapGesture {
                            withAnimation {
                                post = highlight
                            }
                        }
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.never)
        .sheet(item: $post) { highlight in
            HighlightCard(highlight: highlight, selectedUser: $selectedUser, profileView: .constant(false))
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / 0.63)
        }
        .refreshable {
            fetchHighlights(for: user!.uid)
        }
        .onAppear {
            if highlightHolder.highlights.isEmpty {
                fetchHighlights(for: user!.uid)
            }
        }
    }

    func fetchHighlights(for userID: String) {
        let postsCollectionRef = db.collection("Posts")

        var query = postsCollectionRef.whereField("User", isEqualTo: userID)

        if let lastSnapshot = highlightHolder.lastSnapshot {
            query = query.start(afterDocument: lastSnapshot)
        }

        query.limit(to: 10).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching highlights: \(error.localizedDescription)")
                return
            }

            var newHighlights: [HighlightInfo] = []
            let dispatchGroup = DispatchGroup()

            for document in snapshot?.documents ?? [] {
                if let caption = document.data()["ImageCaption"] as? String,
                   let imagePath = document.data()["PostImage"] as? String,
                   let postTime = (document.data()["PostTime"] as? Timestamp)?.dateValue()
                {
                    dispatchGroup.enter()
                    var likedUsersArray: [String] = []
                    if let tempLikedUsersArray = document.data()["Liked Users"] as? [String] {
                        likedUsersArray = tempLikedUsersArray
                    }
                    fetchUsernameAndPhotoURL(for: userID) { username, photoURL in
                        if let username = username, let photoURL = photoURL {
                            let highlight = HighlightInfo(
                                uid: userID, postID: document.documentID,
                                imageName: imagePath, profileImageName: photoURL, username: username, highlightTitle: caption, likedUsers: likedUsersArray, postTime: postTime)
                            if !self.highlightHolder.highlights.contains(where: { $0 == highlight }) {
                                newHighlights.append(highlight)
                            }
                            dispatchGroup.leave()
                        }
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                self.highlightHolder.lastSnapshot = snapshot?.documents.last

                self.highlightHolder.highlights.append(contentsOf: newHighlights)
                print(highlightHolder.highlights)
            }
        }
    }
}

struct ProfileHighlightsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileHighlightsView()
    }
}
