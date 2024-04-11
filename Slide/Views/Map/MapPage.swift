// MapPage.swift
// Slide
// Created by Vaishnav Garodia

import CoreLocation
import FirebaseFirestore
import MapKit
import SwiftUI

struct MapPage: View {
    @State var map = MKMapView()
    @State var manager = CLLocationManager()
    @State var alert = false
    @State var destination: CLLocationCoordinate2D!
    @State var show = false
    @State private var eventView = false
    @State var events: [Event] = []
    @State var selectedEvent: Event = .init()
    @State private var isPresentingCreateEventPage = false
    @State var isFilterActionSheetPresented: Bool = false
    @State var currentFilter: EventFilter = .thisWeek
    
    enum EventFilter {
        case showAll, thisWeek, nextTwoDays, rightNow, verified
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            MapView(map: $map, manager: $manager, alert: $alert, destination: $destination, show: $show, events: $events, eventView: $eventView, selectedEvent: $selectedEvent)
                .ignoresSafeArea()
            
            ZStack(alignment: .topLeading) {
                HStack {
                    Spacer()
                    Button(action: {
                                isFilterActionSheetPresented.toggle()
                            }) {
                                Image(systemName: "line.horizontal.3.decrease.circle")
                                    .padding(-7.5)
                                    .filledBubble()
                                    .frame(width: 60)
                                    .padding(.top, -15)
                            }
                            .actionSheet(isPresented: $isFilterActionSheetPresented) {
                                ActionSheet(title: Text("Filter Events"), buttons: [
                                    currentFilter == .showAll ?
                                        .destructive(Text("Show all Events")) { filterEventsFor(.showAll) } :
                                        .default(Text("Show all Events")) { filterEventsFor(.showAll) },

                                    currentFilter == .thisWeek ?
                                        .destructive(Text("Happening This Week")) { filterEventsFor(.thisWeek) } :
                                        .default(Text("Happening This Week")) { filterEventsFor(.thisWeek) },

                                    currentFilter == .nextTwoDays ?
                                        .destructive(Text("Happening in Next 2 Days")) { filterEventsFor(.nextTwoDays) } :
                                        .default(Text("Happening in Next 2 Days")) { filterEventsFor(.nextTwoDays) },

                                    currentFilter == .rightNow ?
                                        .destructive(Text("Happening Right Now")) { filterEventsFor(.rightNow) } :
                                        .default(Text("Happening Right Now")) { filterEventsFor(.rightNow) },
                                    
                                    currentFilter == .verified ?
                                        .destructive(Text("Verified Events")) { filterEventsFor(.verified) } :
                                        .default(Text("Verified Events")) { filterEventsFor(.verified) },

                                    .cancel()
                                ])
                            }
                    Button(action: {
                        isPresentingCreateEventPage = true
                    }) {
                        Image(systemName: "plus")
                            .padding(-5)
                            .filledBubble()
                            .frame(width: 60)
                            .padding(.trailing)
                            .padding(.top, -15)
                    }
                }
                
                SearchView(map: $map, location: $destination, event: $selectedEvent, detail: $show, eventView: $eventView, placeholder: .constant("Search for Events"), searchForEvents: true, frame: 230)
                    .padding(.top, -15)
            }
            .alert(isPresented: self.$alert) { () -> Alert in
                Alert(title: Text("Error"), message: Text("Please Enable Location In Settings !!!"), dismissButton: .destructive(Text("Ok")))
            }
            
            Button {
                withAnimation {
                    zoomToUserLocation()
                }
            } label: {
                Image(systemName: "location")
                    .filledBubble()
                    .frame(width: 50, height: 50)
                    .padding()
                    .padding(.bottom)
                    .padding(.bottom)
            }
            
            EventDrawer(events: $events, selectedEvent: $selectedEvent, map: $map, eventView: $eventView)
                .onTapGesture {
                    hideKeyboard()
                }
        }
        .onAppear {
            checkHype()
            filterEventsFor(currentFilter)
        }
        .fullScreenCover(isPresented: $isPresentingCreateEventPage) {
            CreateEventPage(isPresentingCreateEventPage: $isPresentingCreateEventPage)
        }
    }
    
    func checkHype() {
        let group = DispatchGroup()
        let docRef = db.collection("HypestEventScore").document("hypestEventScore")
        if hypestEventScore == 0 {
            group.enter()
            docRef.getDocument { scoreDocument, _ in
                if let scoreDocument = scoreDocument, scoreDocument.exists {
                    if let scoreData = scoreDocument.data() {
                        print("Document data: \(scoreData)")
                        if let score = scoreData["score"] as? Int {
                            print("Hypest event score: \(score)")
                            hypestEventScore = score
                        } else {
                            print("Score not found in document.")
                        }
                    }
                    // Update the document with the new score
                }
                group.leave()
            }
            group.notify(queue: .main) {
                filterEventsFor(currentFilter)
            }
        }
    }
    
    func filterEventsFor(_ filter: EventFilter) {
        let currentDate = Date()
        currentFilter = filter
        switch filter {
        case .showAll:
            let twoWeeksFromNow = Calendar.current.date(byAdding: .day, value: 14, to: currentDate)!
            fetchEvents(from: currentDate, to: twoWeeksFromNow)
        case .thisWeek:
            // Logic to get events from the last Sunday to the next Sunday
            let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
            let endOfWeek = Calendar.current.date(byAdding: .day, value: 7, to: startOfWeek)!
            fetchEvents(from: currentDate, to: endOfWeek)
        case .nextTwoDays:
            let twoDaysLater = Calendar.current.date(byAdding: .day, value: 2, to: currentDate)!
            fetchEvents(from: currentDate, to: twoDaysLater)
        case .rightNow:
            fetchEvents(from: currentDate, to: nil)
        case .verified:
            let twoWeeksFromNow = Calendar.current.date(byAdding: .day, value: 14, to: currentDate)!
            fetchEvents(from: currentDate, to: twoWeeksFromNow, verificationNeeded: true)
        }
    }

    func fetchEvents(from startDate: Date, to endDate: Date?, verificationNeeded verifiedRequired: Bool = false) {
        if !verifiedRequired {
            db.collection("Events")
                .whereField("Start", isLessThanOrEqualTo: endDate ?? Date())
                .addSnapshotListener { querySnapshot, error in
                    guard let documents = querySnapshot?.documents else {
                        print("Error fetching documents: \(error!)")
                        return
                    }
                    var newEvents: [Event] = []
                    for document in documents {
                        let data = document.data()
                        let coordinate = data["Coordinate"] as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
                        let ModerationCheckPassed = data["ModerationCheckPassed"] as? String ?? ""
                        let End = (data["End"] as? Timestamp)?.dateValue() ?? Date()
                        if ModerationCheckPassed != "false" && End > startDate{
                            let event = Event(
                                name: data["Name"] as? String ?? "",
                                description: data["Description"] as? String ?? "",
                                address: data["Address"] as? String ?? "",
                                start: (data["Start"] as? Timestamp)?.dateValue() ?? Date(),
                                end: (data["End"] as? Timestamp)?.dateValue() ?? Date(),
                                hostUID: data["HostUID"] as? String ?? "",
                                icon: data["Icon"] as? String ?? "",
                                coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
                                bannerURL: data["BannerURL"] as? String ?? "",
                                hype: data["Hype"] as? String ?? "",
                                id: document.documentID,
                                slides: data["SLIDES"] as? [String] ?? [],
                                highlights: data["Associated Highlights"] as? [String] ?? []
                            )
                            newEvents.append(event)
                        }
                        else if data["HostUID"] as? String == "UuWof49tbwPsq2lZxchVERvtx3I3" {
                            let event = Event(
                                name: data["Name"] as? String ?? "",
                                description: data["Description"] as? String ?? "",
                                address: data["Address"] as? String ?? "",
                                start: (data["Start"] as? Timestamp)?.dateValue() ?? Date(),
                                end: (data["End"] as? Timestamp)?.dateValue() ?? Date(),
                                hostUID: data["HostUID"] as? String ?? "",
                                icon: data["Icon"] as? String ?? "",
                                coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
                                bannerURL: data["BannerURL"] as? String ?? "",
                                hype: data["Hype"] as? String ?? "",
                                id: document.documentID,
                                slides: data["SLIDES"] as? [String] ?? [],
                                highlights: data["Associated Highlights"] as? [String] ?? []
                            )
                            newEvents.append(event)
                        }
                    }
                    events = newEvents
                    print("all current events", events)
                    let currentAnnotations = map.annotations
                    map.removeAnnotations(currentAnnotations)
                    map.addAnnotations(events)
                }
        }
        else {
            db.collection("Events")
                .whereField("Start", isLessThanOrEqualTo: endDate ?? Date())
                .addSnapshotListener { querySnapshot, error in
                    guard let documents = querySnapshot?.documents else {
                        print("Error fetching documents: \(error!)")
                        return
                    }
                    var newEvents: [Event] = []
                    for document in documents {
                        let data = document.data()
                        let coordinate = data["Coordinate"] as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
                        let ModerationCheckPassed = data["ModerationCheckPassed"] as? String ?? ""
                        let End = (data["End"] as? Timestamp)?.dateValue() ?? Date()
                        if ModerationCheckPassed != "false" && End > startDate{
                            let event = Event(
                                name: data["Name"] as? String ?? "",
                                description: data["Description"] as? String ?? "",
                                address: data["Address"] as? String ?? "",
                                start: (data["Start"] as? Timestamp)?.dateValue() ?? Date(),
                                end: (data["End"] as? Timestamp)?.dateValue() ?? Date(),
                                hostUID: data["HostUID"] as? String ?? "",
                                icon: data["Icon"] as? String ?? "",
                                coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
                                bannerURL: data["BannerURL"] as? String ?? "",
                                hype: data["Hype"] as? String ?? "",
                                id: document.documentID,
                                slides: data["SLIDES"] as? [String] ?? [],
                                highlights: data["Associated Highlights"] as? [String] ?? []
                            )
                            if ModerationCheckPassed == "true" {
                                newEvents.append(event)
                            }
                            else if event.hostUID == "UuWof49tbwPsq2lZxchVERvtx3I3" {
                                newEvents.append(event)
                            }
                        }
                    }
                    events = newEvents
                    print("all current events", events)
                    let currentAnnotations = map.annotations
                    map.removeAnnotations(currentAnnotations)
                    map.addAnnotations(events)
                }

        }
    }


    func zoomToUserLocation() {
        if let userLocation = map.userLocation.location {
            let region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015))
            map.setRegion(region, animated: true)
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct MapPage_Previews: PreviewProvider {
    static var previews: some View {
        MapPage()
    }
}
