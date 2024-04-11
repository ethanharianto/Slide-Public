//
//  EligibleEvents.swift
//  Slide
//
//  Created by Thomas on 7/27/23.
//

import Firebase
import FirebaseFirestore

func getEligibleEvents(completion: @escaping ([EventDisplay]?, Error?) -> Void) {
    let db = Firestore.firestore()
    let eventsCollection = db.collection("Events")
    let currentDate = Date()
    let fiveHoursLater = Calendar.current.date(byAdding: .hour, value: 5, to: currentDate)!
    let oneHourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: currentDate)!

    // Create DispatchGroup to handle multiple async queries
    let group = DispatchGroup()
    var eligibleEvents: [EventDisplay] = []

    // Query for events with a start and end time, where the current time lies between them.
    var tempLess: [EventDisplay] = []
    var tempGreater: [EventDisplay] = []
    group.enter()
    eventsCollection.whereField("End", isNotEqualTo: NSNull())
        .whereField("End", isGreaterThanOrEqualTo: currentDate)
        .getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            for document in snapshot!.documents {
                let idDocument = document.documentID
                let data = document.data()
                guard let name = data["Name"] as? String else {
                    continue
                }

                let eventDisplay = EventDisplay(id: idDocument, name: name)
                tempGreater.append(eventDisplay)
            }
            group.leave()
        }
    group.enter()
    eventsCollection.whereField("Start", isLessThanOrEqualTo: currentDate)
        .getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            for document in snapshot!.documents {
                let idDocument = document.documentID
                let data = document.data()
                guard let name = data["Name"] as? String else {
                    continue
                }
                let eventDisplay = EventDisplay(id: idDocument, name: name)
                tempLess.append(eventDisplay)
            }
            group.leave()
        }

    // Query for events with an end time, which have ended within the last hour.
    var tempEnded: [EventDisplay] = []
    var tempEnded1hrAgo: [EventDisplay] = []
    group.enter()
    eventsCollection.whereField("End", isLessThanOrEqualTo: currentDate)
        .getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            for document in snapshot!.documents {
                let idDocument = document.documentID
                let data = document.data()
                guard let name = data["Name"] as? String else {
                    continue
                }
                let eventDisplay = EventDisplay(id: idDocument, name: name)
                tempEnded.append(eventDisplay)
            }
            group.leave()
        }
    group.enter()
    eventsCollection.whereField("End", isGreaterThanOrEqualTo: oneHourAgo)
        .getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            for document in snapshot!.documents {
                let idDocument = document.documentID
                let data = document.data()
                guard let name = data["Name"] as? String else {
                    continue
                }
                let eventDisplay = EventDisplay(id: idDocument, name: name)
                tempEnded1hrAgo.append(eventDisplay)
            }
            group.leave()
        }

    // Query for events without an end time, which are within 5 hours of the start time.
    var tempNoEnd: [EventDisplay] = []
    var tempHasStarted: [EventDisplay] = []
    var tempStarted5Hrs: [EventDisplay] = []
    group.enter()
    eventsCollection.whereField("End", isEqualTo: NSNull())
        .getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            for document in snapshot!.documents {
                let idDocument = document.documentID
                let data = document.data()
                guard let name = data["Name"] as? String else {
                    continue
                }
                let eventDisplay = EventDisplay(id: idDocument, name: name)
                tempNoEnd.append(eventDisplay)
            }
            group.leave()
        }
    group.enter()
    eventsCollection.whereField("Start", isLessThanOrEqualTo: currentDate)
        .getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            for document in snapshot!.documents {
                let idDocument = document.documentID
                let data = document.data()
                guard let name = data["Name"] as? String else {
                    continue
                }
                let eventDisplay = EventDisplay(id: idDocument, name: name)
                tempHasStarted.append(eventDisplay)
            }
            group.leave()
        }
    group.enter()
    eventsCollection.whereField("Start", isGreaterThanOrEqualTo: fiveHoursLater)
        .getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            for document in snapshot!.documents {
                let idDocument = document.documentID
                let data = document.data()
                guard let name = data["Name"] as? String else {
                    continue
                }
                let eventDisplay = EventDisplay(id: idDocument, name: name)
                tempStarted5Hrs.append(eventDisplay)
            }
            group.leave()
        }

    // Notify when all queries are complete and return the eligibleEvents
    group.notify(queue: .main) {
        let set1 = Set(tempGreater)
        let set2 = Set(tempLess)
        let tempOngoing = Array(set1.intersection(set2))
        for i in tempOngoing {
            eligibleEvents.append(i)
        }

        let set11 = Set(tempEnded)
        let set22 = Set(tempEnded1hrAgo)
        let tempEndedWithinAnHour = Array(set11.intersection(set22))
        for i in tempEndedWithinAnHour {
            eligibleEvents.append(i)
        }

        let set111 = Set(tempNoEnd)
        let set222 = Set(tempHasStarted)
        let set333 = Set(tempStarted5Hrs)
        let tempStarted5HrsAgo = Array(set111.intersection(set222).intersection(set333))
        for i in tempStarted5HrsAgo {
            eligibleEvents.append(i)
        }

        completion(eligibleEvents, nil)
    }
}
