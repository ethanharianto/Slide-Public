//  EventGalleryCard.swift
//  Slide
//  Created by Thomas on 7/27/23.

import CoreLocation
import Firebase
import Foundation
import SwiftUI

struct EventGalleryCard: View {
    var event: Event
    @State private var tempHighlights: [HighlightInfo] = [] // Temporary storage for fetched highlights
    @State private var selectedTab = 0 // Keep track of the selected tab index
    @StateObject private var highlightData = HighlightData() // Use @StateObject to manage data flow
    @Binding var profileView: Bool
    @Binding var selectedUser: UserData?
    @Binding var eventView: Bool
    @Binding var selectedEvent: Event?

    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    Button {
                        selectedEvent = event
                        eventView.toggle()
                    } label: {
                        HStack {
                            MiniEventBanner(imageURL: URL(string: event.bannerURL), divider: 10, icon: event.icon)

                            Text(event.name)
                                .fontWeight(.bold)
                        }
                        .padding(-10)
                        .bubbleStyle(color: .primary)
                    }
                    .foregroundColor(.primary)

                    TabView(selection: $selectedTab) {
                        ForEach(tempHighlights.indices, id: \.self) { index in
                            HighlightCard(highlight: tempHighlights[index], selectedUser: $selectedUser, profileView: $profileView)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Use PageTabViewStyle for the carousel effect
                    .aspectRatio(0.63, contentMode: .fit)
                    .onChange(of: tempHighlights) { newHighlights in
                        highlightData.highlights = newHighlights // Update the @StateObject with the fetched highlights
                    }
                    .onAppear {
                        // Fetch highlight info when the view appears
                        fetchHighlights()
                    }
                    .frame(
                        width: UIScreen.main.bounds.width,
                        height: UIScreen.main.bounds.width / 0.63
                    )
                }
            }
            .edgesIgnoringSafeArea(.all)

            CustomSegmentedView(totalTabs: tempHighlights.count, selectedTab: $selectedTab)
                .padding(.bottom)
        }
    }

    private func fetchHighlights() {
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
            let dispatchGroup = DispatchGroup()
            for postId in event.highlights {
                dispatchGroup.enter()
                getHighlightInfo(highlightID: postId) { highlightInfo in
                    if let highlightInfo = highlightInfo {
                        //                    if !tempHighlights.contains(highlightInfo) && highlightInfo.uid != Auth.auth().currentUser!.uid {
                        if !tempHighlights.contains(highlightInfo) && !reportedHighlightsList.contains(highlightInfo.postID) {
                            tempHighlights.append(highlightInfo)
                        }
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                // All async calls are completed, the @onChange will be called to update highlightData
            }
        }
    }
}

struct SmallEventGalleryCard: View {
    var eventID: String
    @State private var event: Event = .init()
    @State private var eventView = false
    @State private var selectedTab = 0

    var body: some View {
        Button {
            withAnimation {
                eventView.toggle()
            }
        } label: {
            ZStack(alignment: .bottomLeading) {
                if event.bannerURL.isEmpty {
                    ZStack {
                        Rectangle()
                            .fill(LinearGradient(colors: [.accentColor, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        Image(systemName: event.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width / 9, height: UIScreen.main.bounds.width / 9)
                            .foregroundColor(.white)
                    }
                } else {
                    SmallEventBanner(imageURL: URL(string: event.bannerURL))
                }
                Text(event.name)
                    .padding(2)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
        }
        .frame(width: UIScreen.main.bounds.width / 2.25, height: UIScreen.main.bounds.width / 2.25)
        .background(Color.blue)
        .cornerRadius(10)
        .onAppear {
            fetchEventDetails(for: eventID) { temp in
                event = temp!
            }
        }
        .sheet(isPresented: $eventView) {
            EventDetailsView(event: $event, eventView: $eventView)
        }
    }

    func fetchEventDetails(for eventID: String, completion: @escaping (Event?) -> Void) {
        let eventRef = db.collection("Events").document(eventID)

        eventRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let coordinate = data?["Coordinate"] as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
                let event = Event(
                    name: data?["Name"] as? String ?? "",
                    description: data?["Description"] as? String ?? "",
                    address: data?["Address"] as? String ?? "",
                    start: (data?["Start"] as? Timestamp)?.dateValue() ?? Date(),
                    end: (data?["End"] as? Timestamp)?.dateValue() ?? Date(),
                    hostUID: data?["HostUID"] as? String ?? "",
                    icon: data?["Icon"] as? String ?? "",
                    coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
                    bannerURL: data?["BannerURL"] as? String ?? "",
                    hype: data?["Hype"] as? String ?? "",
                    id: document.documentID,
                    slides: data?["SLIDES"] as? [String] ?? [],
                    highlights: data?["Associated Highlights"] as? [String] ?? []
                )
                completion(event)
            } else {
                print("Error fetching event document: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            }
        }
    }
}

class HighlightData: ObservableObject {
    @Published var highlights: [HighlightInfo] = []
}
