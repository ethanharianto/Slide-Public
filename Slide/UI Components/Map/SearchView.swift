//
//  SearchView.swift
//  Slide
//
//  Created by Vaishnav Garodia on 7/26/23.
//

import CoreLocation
import MapKit
import SwiftUI

struct SearchView: View {
    @State var result: [SearchData] = []
    @Binding var map: MKMapView
    @Binding var location: CLLocationCoordinate2D!
    @Binding var event: Event
    @Binding var detail: Bool
    @Binding var eventView: Bool
    @Binding var placeholder: String
    var searchForEvents: Bool = false
    @State var txt = ""
    @State var createEventSearch: Bool = false
    @State var events: [Event] = []
 
    var frame: CGFloat
    var body: some View {
        ZStack {
            if !self.result.isEmpty && self.txt != "" {
                Rectangle()
                    .foregroundColor(.black.opacity(0.5))
                    .ignoresSafeArea()
            }
            GeometryReader { _ in
                VStack(alignment: .leading) {
                    SearchBar(map: self.$map, result: self.$result, txt: self.$txt, placeholder: self.$placeholder)
                        .frame(width: self.frame)
                        .padding(-25)
                        .bubbleStyle(color: .primary)
                        .padding(.leading, 10)
                        .onChange(of: self.txt) { _ in
                            if self.searchForEvents {
                                self.events.removeAll()
                                searchEvents(eventName: self.txt) { search in
                                    self.events = search
                                }
                            }
                        }
                        .shadow(radius: 10)
                    
                    if !self.result.isEmpty && self.txt != "" {
                        List {
                            if !self.events.isEmpty {
                                Section {
                                    ForEach(self.events, id: \.id) { event in
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(event.name)
                                                Text(event.eventDescription)
                                                    .font(.caption)
                                            }
                                            Spacer()
                                            MiniEventBanner(imageURL: URL(string: event.bannerURL), divider: 10, icon: event.icon)
                                        }
                                        .listRowBackground(Color.clear)
                                        .foregroundColor(.white)
                                        .onTapGesture {
                                            withAnimation {
                                                self.dismissKeyboard()
                                                self.event = event
                                                self.result.removeAll()
                                                self.txt = ""
                                                self.eventView.toggle()
                                            }
                                        }
                                    }
                                } header: {
                                    Text("Events")
                                        .font(.caption)
                                }
                            }
                           
                            Section {
                                ForEach(self.result) { i in
                                    VStack(alignment: .leading) {
                                        Text(i.name)
                                            .foregroundColor(.white)
                                                        
                                        Text(i.address)
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    }
                                    .onTapGesture {
                                        self.dismissKeyboard()
                                        self.searchLocation(query: i.result)
                                        // Clear the search results when list item is tapped
                                        self.result.removeAll()
                                    }
                                    .listRowBackground(Color.clear)
                                }
                            } header: {
                                Text("Locations")
                                    .font(.caption)
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            
            .padding()
        }
    }

    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func searchLocation(query: MKLocalSearchCompletion) {
        let req = MKLocalSearch.Request(completion: query)
        req.region = self.map.region
        var lat = 0.0
        var lon = 0.0
        let search = MKLocalSearch(request: req)
        search.start { response, _ in
            guard let coordinate = response?.mapItems[0].placemark.coordinate else {
                return
            }

            guard let name = response?.mapItems[0].name else {
                return
            }

            lat = coordinate.latitude
            lon = coordinate.longitude

            print(lat)
            print(lon)
            self.location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            print(name)
            self.UpdateMap(placeName: name)
        }
    }
    
    func UpdateMap(placeName: String?) {
        if self.createEventSearch {
            var addressString: String = ""
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: location, span: span)
            let point = MKPointAnnotation()
            point.subtitle = "Event location"
            point.coordinate = self.location
            
            let decoder = CLGeocoder()
            decoder.reverseGeocodeLocation(CLLocation(latitude: self.location.latitude, longitude: self.location.longitude)) { places, err in
                
                if err != nil {
                    print((err?.localizedDescription)!)
                    return
                }
                let pm = places! as [CLPlacemark]
                if pm.count > 0 {
                    let pm = places![0]
                    if placeName != nil {
                        addressString = addressString + (placeName ?? "") + ", "
                    }
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.subThoroughfare != nil {
                        addressString = addressString + pm.subThoroughfare! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality!
                    }
                }
                
                self.event.address = addressString
                point.title = places?.first?.name ?? ""
                self.detail = true
            }
            self.map.removeAnnotations(self.map.annotations)
            self.map.addAnnotation(point)
            self.map.setRegion(region, animated: true)
            
        } else {
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: self.location, span: span)
            self.map.setRegion(region, animated: true)
        }
    }
}

struct SearchBar: UIViewRepresentable {
    @Binding var map: MKMapView
    @Binding var result: [SearchData]
    @Binding var txt: String
    @Binding var placeholder: String
    
    
    func makeCoordinator() -> Coordinator {
        return SearchBar.Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UISearchBar {
        let view = UISearchBar()
        view.clearBackgroundColor()
        view.placeholder = self.placeholder
        view.isTranslucent = false
        view.searchBarStyle = .prominent
        view.autocorrectionType = .no
        view.autocapitalizationType = .none
        view.delegate = context.coordinator
        view.clipsToBounds = true
        return view
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {}
}

class Coordinator: NSObject, UISearchBarDelegate, MKLocalSearchCompleterDelegate {
    var parent: SearchBar
    private lazy var searchCompleter: MKLocalSearchCompleter = {
        let completer = MKLocalSearchCompleter()
        completer.delegate = self
        return completer
    }()

    var searchResults = [MKLocalSearchCompletion]()
    
    init(parent: SearchBar) {
        self.parent = parent
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.parent.txt = searchText
        self.searchCompleter.region = self.parent.map.region
        self.searchCompleter.queryFragment = searchText
    }
    
    // This method declares gets called whenever the searchCompleter has new search results
    // If you wanted to do any filter of the locations that are displayed on the the table view
    // this would be the place to do it.
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Setting our searcResults variable to the results that the searchCompleter returned
        self.searchResults = completer.results
        DispatchQueue.main.async {
            self.parent.result.removeAll()
            for i in 0 ..< self.searchResults.count {
                let temp = SearchData(id: i, name: self.searchResults[i].title, address: self.searchResults[i].subtitle, result: self.searchResults[i])
                if temp.address != "Search Nearby" && temp.address != "" {
                    self.parent.result.append(temp)
                }
            }
        }
    }

    // This method is called when there was an error with the searchCompleter
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error occured")
    }
}

struct SearchData: Identifiable, Equatable {
    var id: Int
    var name: String
    var address: String
    var result: MKLocalSearchCompletion
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(map: .constant(MKMapView()), location: .constant(CLLocationCoordinate2D()), event: .constant(Event()), detail: .constant(true), eventView: .constant(false), placeholder: .constant(""), frame: 400)
    }
}
