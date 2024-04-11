//  Profile View.swift
//  Slide
//  Created by Ethan Harianto on 12/21/22.

import Firebase
import FirebaseAuth
import SwiftUI

struct ProfileView: View {
    // functions used: fetchCurrentFriendsCount
    @StateObject private var profileInfo = ProfileInfo()
    @State private var user = Auth.auth().currentUser
    @State private var tab = "Highlights"
    @State private var editProfilePic = false
    @State private var eventView = false
    
    var body: some View {
        FancyScrollView(title: "",
                        headerHeight: 225,
                        scrollUpHeaderBehavior: .parallax,
                        scrollDownHeaderBehavior: .sticky,
                        header: { VStack {
                            Spacer()
                                .frame(height: 20)
                            ZStack {
                                HStack {
                                    VStack(alignment: .center) {
                                        Text("\(profileInfo.highlights.count)")
                                        Text(profileInfo.highlights.count == 1 ? "Highlight" : "Highlights")
                                    }
                                    .padding(.leading)
                    
                                    Spacer()
                    
                                    VStack {
                                        Text("\(profileInfo.friendsCount)")
                                        Text(profileInfo.friendsCount == 1 ? "Friend" : "Friends")
                                    }
                                    .padding(.trailing)
                                }
                
                                ZStack {
                                    Circle()
                                        .stroke(lineWidth: 2.5)
                                        .fill(Color.accentColor)
                                        .frame(width: 115)
                    
                                    ProfilePicture()
                                }
                            }
            
                            Text(user?.displayName ?? "SimUser")
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        } }) {
            VStack(alignment: .center) {
                HStack {
                    Button {
                        withAnimation {
                            tab = "Highlights"
                        }
                    } label: {
                        if tab == "Highlights" {
                            Text("Highlights").underlineGradient()
                        } else {
                            Text("Highlights").emptyBubble()
                        }
                    }

                    Button {
                        withAnimation {
                            tab = "Events"
                        }
                    } label: {
                        if tab == "Events" {
                            Text("Events").underlineGradient()
                        } else {
                            Text("Events").emptyBubble()
                        }
                    }
                }
                .padding()
                
                if tab == "Highlights" {
                    ProfileHighlightsView(highlightHolder: profileInfo)
                        .transition(.move(edge: .leading))
                } else {
                    ProfileEventsView()
                        .transition(.move(edge: .trailing))
                }
            }
        }
        
        .onAppear {
            fetchCurrentFriendsCount(highlightHolder: profileInfo)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
