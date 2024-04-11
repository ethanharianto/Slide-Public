//  ProfileEventsView.swift
//  Slide
//  Created by Ethan Harianto on 7/26/23.

import SwiftUI
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Combine

struct ProfileEventsView: View {
    @State private var eventIDs: [String] = []  // Holds the event IDs

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(eventIDs, id: \.self) { eventID in
                    SmallEventGalleryCard(eventID: eventID)
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.never)
        .onAppear {
            loadEventIDs()
        }
    }
    
    // Load the event IDs from the user's document
    private func loadEventIDs() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let group = DispatchGroup() // Create a DispatchGroup

        let userDocumentRef = db.collection("Users").document(currentUserID)
        
        group.enter() // Notify the group that a task has started
        
        userDocumentRef.getDocument { document, error in
            if let document = document, document.exists {
                if let eventIDsArray = document.data()?["Events"] as? [String] {
                    eventIDs = eventIDsArray
                    group.leave()
                }
            }
        }
        
        // This block will be executed when all tasks in the group are done
        group.notify(queue: .main) {
            return
        }
    }
}

