//  searchEvents.swift
//  Slide
//  Created by Ethan Harianto on 8/25/23.

import CoreLocation
import FirebaseFirestore

func searchEvents(eventName: String, completion: @escaping ([Event]) -> Void) {
    let eventNameLowercased = eventName.lowercased()
    db.collection("Events")
        .getDocuments { snapshot, error in
            if let error = error {
                print("Error searching events: \(error.localizedDescription)")
                completion([])
                return
            }

            var events: [Event] = []
            for document in snapshot?.documents ?? [] {
                let data = document.data()
                let eventNameFirestore = data["Name"] as? String ?? ""

                if eventNameFirestore.lowercased().starts(with: eventNameLowercased) {
                    let coordinate = data["Coordinate"] as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
                    let event = Event(
                        name: eventNameFirestore,
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
                    events.append(event)
                }
            }
            completion(events)
        }
}
