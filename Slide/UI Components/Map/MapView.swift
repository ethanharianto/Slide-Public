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
import UIKit
struct MapView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        return MapView.Coordinator(parent1: self)
    }

    @Binding var map: MKMapView
    @Binding var manager: CLLocationManager
    @Binding var alert: Bool
    @Binding var destination: CLLocationCoordinate2D!
    @Binding var show: Bool
    @Binding var events: [Event]
    @Binding var eventView: Bool
    @Binding var selectedEvent: Event

    func makeUIView(context: Context) -> MKMapView {
        map.delegate = context.coordinator
        manager.delegate = context.coordinator
        map.mapType = .standard
        map.showsUserLocation = true
        map.pointOfInterestFilter = .excludingAll
        map.overrideUserInterfaceStyle = .dark
        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {}

    class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        var parent: MapView

        init(parent1: MapView) {
            parent = parent1
        }

        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .denied {
                parent.alert.toggle()
            } else {
                parent.manager.startUpdatingLocation()
                if let location = parent.manager.location?.coordinate {
                    let span = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
                    let region = MKCoordinateRegion(center: location, span: span)
                    parent.map.setRegion(region, animated: true)
                }
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            var annotationView = MKMarkerAnnotationView()
            // If the annotation isn't from a capital city, it must return nil so iOS uses a default view.
            guard annotation is Event else { return nil }
            let eventData = annotation as! Event
            // Define a reuse identifier. This is a string that will be used to ensure we reuse annotation views as much as possible.
            var color = UIColor.red
            var identifier = ""
            switch eventData.hype {
                case "high":
                    identifier = "high"
                    color = .red
                case "medium":
                    identifier = "medium"
                    color = .yellow
                case "low":
                    identifier = "low"
                    color = .blue
                default:
                    identifier = "low"
                    color = .blue
            }

            if let dequedView = mapView.dequeueReusableAnnotationView(
                withIdentifier: identifier)
                as? MKMarkerAnnotationView
            {
                annotationView = dequedView
            } else {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView.canShowCallout = true

                // Create a new UIButton using the built-in .detailDisclosure type. This is a small blue "i" symbol with a circle around it.
                let btn = UIButton(type: .detailDisclosure)
                annotationView.rightCalloutAccessoryView = btn
            }
            annotationView.animatesWhenAdded = true
            annotationView.markerTintColor = color
            annotationView.glyphImage = UIImage(systemName: eventData.icon)
            annotationView.glyphTintColor = .white
            return annotationView
        }

        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let event = view.annotation as? Event else { return }
            print("annotation got tapped")
            parent.selectedEvent = event
            parent.eventView = true
        }
    }
}
