import Combine
import Firebase
import FirebaseFirestoreSwift
import SwiftUI

struct EventGallery: View {
    var eventID: String
    @State private var posts: [HighlightInfo] = [] // Holds the list of associated posts
    @State private var highlight: HighlightInfo? // Holds the selected highlight
    @State private var userData: UserData?
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(posts) { post in
                    Button(action: {
                        highlight = post // Set the selected highlight
                    }) {
                        HighlightImageMini(imageURL: URL(string: post.imageName)!)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .onAppear {
            loadAssociatedPosts()
        }
        .sheet(item: $highlight) { highlight in
            // Present the highlight card using the sheet modifier
            HighlightCard(highlight: highlight, selectedUser: $userData, profileView: .constant(false))
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / 0.63)
        }
    }
    
    private func loadAssociatedPosts() {
        let user = Auth.auth().currentUser

        var friendList: [String] = []
        var reportedHighlightsList: [String] = []
        guard (user?.uid) != nil else {
            return
        }
        
        let initialGroup = DispatchGroup()
        initialGroup.enter()
        fetchFriendListAndReports { friendListFetched, highlightsReportedFetched, error in
            if let error = error {
                print("Error: \(error)")
                initialGroup.leave()
            } else if let friendListFetched = friendListFetched, let highlightsReportedFetched = highlightsReportedFetched {
                friendList = friendListFetched
                reportedHighlightsList = highlightsReportedFetched
                initialGroup.leave()
            }
        }
        
        initialGroup.notify(queue: .main) {
            
            let eventDocumentRef = Firestore.firestore().collection("Events").document(eventID)
            let group = DispatchGroup() // Create a DispatchGroup
            var temp: [HighlightInfo] = []
            
            eventDocumentRef.getDocument { document, _ in
                if let document = document, document.exists {
                    if let associatedHighlights = document.data()?["Associated Highlights"] as? [String] {
                        for highlightID in associatedHighlights {
                            let highlightDocumentRef = Firestore.firestore().collection("Posts").document(highlightID)
                            highlightDocumentRef.getDocument { document2, _ in
                                if let document2 = document2, document2.exists {
                                    let userLikes = document2.data()?["Liked Users"] as? [String] ?? []
                                    if let uid = document2.data()?["User"] as? String,
                                       let imageName = document2.data()?["PostImage"] as? String,
                                       let highlightTitle = document2.data()?["ImageCaption"] as? String,
                                       let postTime = (document2.data()?["PostTime"] as? Timestamp)?.dateValue()
                                    {
                                        // Fetch the user document using the extracted uid
                                        group.enter() // Enter the DispatchGroup before starting each fetchUserDetails call
                                        fetchUserDetails(userID: uid) { userDetails in
                                            let userDetails = userDetails
                                            userData = userDetails
                                            if !reportedHighlightsList.contains(document2.documentID) {
                                                temp.append(HighlightInfo(uid: uid, postID: document2.documentID, imageName: imageName, profileImageName: userData?.photoURL ?? imageName, username: userData?.username ?? "", highlightTitle: highlightTitle, likedUsers: userLikes, postTime: postTime))
                                            }
                                            group.leave() // Leave the DispatchGroup after the fetchUserDetails call is completed
                                        }
                                    }
                                }
                                group.notify(queue: .main) {
                                    posts = temp
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
