//  EventDetailsView.swift
//  Slide
//  Created by Ethan Harianto on 8/18/23.

import SwiftUI

struct EventDetailsView: View {
    @State private var selectedTab = 0
    @Binding var event: Event
    @Binding var eventView: Bool
    var gallery: Bool = true

    var body: some View {
        TabView(selection: $selectedTab) {
            VStack {
                EventDetails(event: event, fromMap: true, eventView: $eventView, showEditButton: true)
                Spacer()
            }
            if gallery && !event.highlights.isEmpty {
                EventGallery(eventID: event.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        if selectedTab == 0 && !event.highlights.isEmpty {
            Text("Swipe to see highlights posted to this event")
                .padding(.bottom, 2)
        }
    }
}
