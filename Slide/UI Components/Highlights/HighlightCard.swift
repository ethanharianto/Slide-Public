// HighlightCard.swift
// Slide
// Created by Ethan Harianto on 7/20/23.

import Firebase
import FirebaseAuth
import FirebaseFirestore
import Kingfisher
import SwiftUI
import UIKit

struct HighlightCard: View {
    let user = Auth.auth().currentUser
    @State var highlight: HighlightInfo
    @State private var currentUserLiked: Bool = false
    @Binding var selectedUser: UserData?
    @Binding var profileView: Bool
    @State private var isShowingAlert = false
    @State private var reportDetails = ""

    var body: some View {
        ZStack {
            HighlightImage(imageURL: URL(string: highlight.imageName)!)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 15))
            VStack {
                HStack {
                    HStack {
                        UserProfilePictures(photoURL: highlight.profileImageName, dimension: 35)
                            .padding(.trailing, -5)
                            .onTapGesture {
                                if highlight.uid != user!.uid {
                                    selectedUser = UserData(userID: highlight.uid, username: highlight.username, photoURL: highlight.profileImageName)
                                    profileView.toggle()
                                }
                            }
                        VStack(alignment: .leading) {
                            Text(highlight.username)
                                .foregroundColor(.primary)
                                .fontWeight(.semibold)
                                .onTapGesture {
                                    if highlight.uid != user!.uid {
                                        selectedUser = UserData(userID: highlight.uid, username: highlight.username, photoURL: highlight.profileImageName)
                                        profileView.toggle()
                                    }
                                }
                            if !highlight.highlightTitle.isEmpty {
                                Text(highlight.highlightTitle)
                                    .font(.caption)
                                    .fontWeight(.thin)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .background(BlurView(style: .systemMaterial).cornerRadius(15))
                    .padding()
                    .shadow(radius: 10)
                    Spacer()
                    Button(action: {
                        isShowingAlert = true
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.primary)
                            .padding()
                            .cornerRadius(10)
                    }
                    .contextMenu {
                        Button(action: {
                            // Handle the "Report" action here
                            isShowingAlert = true
                        }) {
                            Text("Report Image")
                            Image(systemName: "exclamationmark.triangle.fill")
                        }
                    }
                }
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        LikePost()
                        withAnimation {
                            currentUserLiked.toggle()
                        }
                    }) {
                        VStack {
                            Image(systemName: currentUserLiked ? "heart.fill" : "heart")
                            Text("\(highlight.likedUsers.count)")
                                .font(.caption)
                        }
                        .foregroundColor(currentUserLiked ? .accentColor : .white)
                        .padding()
                        .background(BlurView(style: .systemMaterial).clipShape(Circle()))
                    }
                    .padding()
                    .shadow(radius: 10)
                }
            }
        }
        .onAppear {
            currentUserLiked = isCurUserLiking()
        }
        .alert("Report Image", isPresented: $isShowingAlert, actions: {
            TextField("Please add more details", text: $reportDetails)
            Button("Report", action: { reportImage() })
            Button("Cancel", role: .cancel, action: {})
        }, message: {
            Text("Do you want to report this image?")
        })
    }

//     This function has to add the image to a reported field in the user document and then it also needs to add the report to a reports database in firebase
    func reportImage() {
        let currentUser = Auth.auth().currentUser!.uid
        // Step 1: Deal with adding to the user document
        let userDocRef = db.collection("Users").document(currentUser)
        userDocRef.getDocument { document, _ in
            if let document = document, document.exists {
                var highlightReportList = document.data()?["highlightsReported"] as? [String] ?? []
                highlightReportList.append(highlight.postID)
                userDocRef.updateData(["highlightsReport": highlightReportList])
            }
        }

        // Step 2: Deal with adding to the report database
        let highlightReportDoc = db.collection("HighlightReports").document()
        highlightReportDoc.setData(["highlightID": highlight.postID, "reportDescription": reportDetails, "reporterID": currentUser]) { err in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
        }

        print("Image reported")
    }

    func isCurUserLiking() -> Bool {
        guard let currentUserID = user?.uid else {
            return false
        }
        return highlight.likedUsers.contains(currentUserID)
    }

    func LikePost() {
        // 1. Add currentUserID to currentUserLiked and update likedUsers in highlight
        guard let currentUserID = user?.uid else {
            return
        }
        // 2. Update the corresponding post in the database
        let postID = highlight.postID
        let postRef = db.collection("Posts").document(postID)
        print("POST ID")
        print(postID)

        postRef.getDocument { document, _ in
            if let document = document, document.exists {
                var likedUsersList = document.data()?["Liked Users"] as? [String] ?? []
                if likedUsersList.contains(currentUserID) {
                    likedUsersList.removeAll { $0 == currentUserID }
                } else {
                    likedUsersList.append(currentUserID)
                }
                postRef.updateData(["Liked Users": likedUsersList])
                highlight.likedUsers = likedUsersList
            } else {
                print("Event document not found!")
            }
        }
    }
}

struct HighlightCard_Previews: PreviewProvider {
    static var previews: some View {
        HighlightCard(highlight: HighlightInfo(uid: "", postID: "s", imageName: "https://i.natgeofe.com/n/548467d8-c5f1-4551-9f58-6817a8d2c45e/NationalGeographic_2572187_square.jpg", profileImageName: "", username: "tommy", highlightTitle: "", likedUsers: [], postTime: .now), selectedUser: .constant(nil), profileView: .constant(false))
    }
}


struct SmallHighlightCard: View {
    var highlight: HighlightInfo
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            KFImage(URL(string: highlight.imageName))
                .resizable()
                .fade(duration: 0.25)
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width / 2.25, height: UIScreen.main.bounds.width / 2.25)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Text(highlight.highlightTitle)
                .padding(2)
                .foregroundColor(.white)
                .background(Color.black.opacity(0.6))
                .cornerRadius(10)
        }
    }
}
