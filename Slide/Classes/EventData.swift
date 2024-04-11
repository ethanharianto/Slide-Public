import MapKit
import SwiftUI
import ObjectiveC
import FirebaseFirestore

class Event: NSObject, MKAnnotation {
    var name: String
    var title: String?
    var subtitle: String?
    var eventDescription: String
    var host, hostName, address: String
    var start, end: Timestamp
    var hostUID, icon: String
    var coordinate: CLLocationCoordinate2D
    var bannerURL: String
    
    init(name: String, description: String, host: String, hostName: String, address: String, start: Timestamp, end: Timestamp, hostUID: String, icon: String, coordinate: CLLocationCoordinate2D, bannerURL: String) {
        self.name = name
        self.title = name
        self.eventDescription = description
        self.subtitle = description
        self.host = host
        self.hostName = hostName
        self.address = address
        self.start = start
        self.end = end
        self.hostUID = hostUID
        self.icon = icon
        self.coordinate = coordinate
        self.bannerURL = bannerURL
    }
}
