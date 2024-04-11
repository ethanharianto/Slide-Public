//
//  MapView.swift
//  Slide
//
//  Created by Vaishnav Garodia on 7/26/23.
//

import CoreLocation
import FirebaseFirestore
import MapKit
import SwiftUI

struct CreateEventView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        return CreateEventView.Coordinator(parent1: self)
    }

    @Binding var map: MKMapView
    @Binding var event: Event
    @Binding var alert: Bool
    @Binding var show: Bool
    @Binding var destination: CLLocationCoordinate2D!
    @Binding var searchForAddress: Bool
    @State private var manager = CLLocationManager()

    func makeUIView(context: Context) -> MKMapView {
        map.delegate = context.coordinator
        manager.delegate = context.coordinator
        if let location = manager.location?.coordinate {
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: location, span: span)
            map.setRegion(region, animated: true)
        }
        let gesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.tap(ges:)))
        map.addGestureRecognizer(gesture)
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
    
    class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        var parent: CreateEventView
        
        init(parent1: CreateEventView) {
            self.parent = parent1
        }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .denied {
                self.parent.alert.toggle()
            }
            else {
                parent.manager.startUpdatingLocation()
                if let location = parent.manager.location?.coordinate {
                    let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    let region = MKCoordinateRegion(center: location, span: span)
                    parent.map.setRegion(region, animated: true)
                }
            }
        }
        
        @objc func tap(ges: UITapGestureRecognizer) {
            // TOOD: Add a new box in the event creation view in this case asking for location name as that does not get updated correctly.
            let location = ges.location(in: parent.map)
            let mplocation = parent.map.convert(location, toCoordinateFrom: parent.map)
            
            var addressString = ""
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: mplocation, span: span)
            let point = MKPointAnnotation()
            point.subtitle = "Event location"
            point.coordinate = mplocation
            
            parent.destination = mplocation
           
            
            let decoder = CLGeocoder()
            decoder.reverseGeocodeLocation(CLLocation(latitude: mplocation.latitude, longitude: mplocation.longitude)) { places, err in
                
                if err != nil {
                    print((err?.localizedDescription)!)
                    return
                }
                
                let pm = places! as [CLPlacemark]
                if pm.count > 0 {
                    let pm = places![0]
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.subThoroughfare != nil {
                        addressString = addressString + pm.subThoroughfare! + " "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality!
                    }
                }
                
                self.parent.event.address = addressString
                point.title = places?.first?.name ?? ""
                withAnimation {
                    self.parent.show = true
                    self.parent.searchForAddress.toggle()
                }
            }
                
            self.parent.map.setRegion(region, animated: true)
            self.parent.map.removeAnnotations(self.parent.map.annotations)
            self.parent.map.addAnnotation(point)
        }
    }
}

struct CreateEventView_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventView(map: .constant(MKMapView()), event: .constant(Event()), alert: .constant(false), show: .constant(true), destination: .constant(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)), searchForAddress: .constant(false))
    }
}
