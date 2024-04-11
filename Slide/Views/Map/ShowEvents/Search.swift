////
////  Search.swift
////  Slide
////
////  Created by Ethan Harianto on 8/2/23.
////
//
//import MapKit
//import SwiftUI
//
//struct Search: View {
//    @State var result: [SearchData]? = []
//    @Binding var map: MKMapView?
//    @Binding var location: CLLocationCoordinate2D?
//    @State var event: Event?
//    @Binding var detail: Bool
//    @State private var searchQuery: String? = ""
//    @State var createEventSearch: Bool? = false
//    @ObservedObject private var searchViewModel: SearchViewModel
//
//    var frame: CGFloat?
//
//    init(map: MKMapView, location: Binding<CLLocationCoordinate2D?>, detail: Binding<Bool>, frame: CGFloat = 0) {
//        self._location = location
//        self._detail = detail
//        self.searchViewModel = SearchViewModel(map: map) // Initialize the SearchViewModel with the map
//        self.frame = frame
//    }
//
//
//
//    var body: some View {
//        ZStack {
//            if !self.result!.isEmpty && self.searchQuery != "" {
//                Rectangle()
//                    .foregroundColor(.black.opacity(0.5))
//                    .ignoresSafeArea()
//            }
//            GeometryReader { _ in
//                VStack(alignment: .leading) {
//                    // Add the new TextField here
//                    TextField("Search for events", text: $searchViewModel.searchQuery)
//                        .onChange(of: searchViewModel.searchQuery) { newSearchQuery in
//                            searchViewModel.updateSearchQuery(query: newSearchQuery)
//                        }
//                        .onChange(of: searchViewModel.result) { _ in
//                            // The searchViewModel.result has been updated, so we can use it directly
//                            self.result = searchViewModel.result
//                        }
//                        .bubbleStyle(color: .primary)
//                        .padding(.horizontal, 20)
//
//                    if !self.result!.isEmpty && self.searchQuery != "" {
//                        List(self.result!) { i in
//                            VStack(alignment: .leading) {
//                                Text(i.name)
//                                    .foregroundColor(.white)
//
//                                Text(i.address)
//                                    .font(.caption)
//                                    .foregroundColor(.white)
//                            }
//                            .listRowBackground(Color.clear)
//                            .onTapGesture {
//                                self.dismissKeyboard()
////                                self.searchLocation(query: i.result)
//                                // Clear the search results when list item is tapped
//                                self.result!.removeAll()
//                            }
//                        }
//                        .scrollContentBackground(.hidden)
//                    }
//                }
//            }
//            .padding()
//        }
//    }
//
//    func dismissKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//
//    func searchLocation(query: String, completion: @escaping ([SearchData]) -> Void) {
//        let req = MKLocalSearch.Request()
//        req.naturalLanguageQuery = query
//        req.region = map!.region
//        let search = MKLocalSearch(request: req)
//        search.start { response, _ in
//            guard let items = response?.mapItems else {
//                // If there are no search results, call the completion closure with an empty array
//                completion([])
//                return
//            }
//
//            // Create an array to store the search results
//            var searchResults: [SearchData] = []
//            for (index, item) in items.enumerated() {
//                let searchResult = SearchData(id: index, name: item.name ?? "", address: item.placemark.title ?? "", result: MKLocalSearchCompletion())
//                searchResults.append(searchResult)
//            }
//
//            // Call the completion closure with the array of search results
//            completion(searchResults)
//        }
//    }
//}
//
//class SearchViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
//    @Published var result: [SearchData] = []
//    @Published var searchQuery: String = "" {
//        didSet {
//            // Call the searchLocation function whenever the searchQuery changes
//            searchLocation(query: searchQuery)
//        }
//    }
//
//    var map: MKMapView // Add the map variable here
//
//    init(map: MKMapView) {
//        self.map = map
//        super.init()
//        let completer = MKLocalSearchCompleter()
//        completer.delegate = self
//        completer.region = map.region // Use the map's region for the search
//        completer.queryFragment = searchQuery
//    }
//
//    func searchLocation(query: String) {
//        let completer = MKLocalSearchCompleter()
//        completer.delegate = self
//        completer.region = map.region // Use the map's region for the search
//        completer.queryFragment = query
//    }
//
//    func updateSearchQuery(query: String) {
//        searchQuery = query
//    }
//
//    // MARK: MKLocalSearchCompleterDelegate
//
//    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
//        // Create an array to store the search results
//        var searchResults: [SearchData] = []
//        for (index, result) in completer.results.enumerated() {
//            let searchData = SearchData(id: index, name: result.title, address: result.subtitle, result: result)
//            searchResults.append(searchData)
//        }
//
//        // Pass the search results back to the caller
//        DispatchQueue.main.async {
//            self.result = searchResults
//        }
//    }
//
//    // This method is called when there was an error with the searchCompleter
//    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
//        print("Error occurred")
//    }
//}
//
//struct Search_Previews: PreviewProvider {
//    static var previews: some View {
//        Search(map: MKMapView(), location: .constant(CLLocationCoordinate2D()), detail: .constant(true))
//    }
//}
