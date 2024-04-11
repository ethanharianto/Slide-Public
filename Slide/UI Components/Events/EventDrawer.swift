//  EventDrawer.swift
//  Slide
//  Created by Ethan Harianto on 8/16/23.

import FirebaseAuth
import MapKit
import SwiftUI

struct EventDrawer: View {
    @Binding var events: [Event]
    @Binding var selectedEvent: Event
    @Binding var map: MKMapView
    @Binding var eventView: Bool
    // Gesture Properties...
    @State var offset: CGFloat = 10
    @State var lastOffset: CGFloat = 10
    @State var storedOffset: CGFloat = 0
    @GestureState var gestureOffset: CGFloat = 0
    var sortedEvents: [Event] {
        return events.sorted { $0.slides.count > $1.slides.count }
    }
    
    var body: some View {
        GeometryReader { proxy -> AnyView in
            let height = proxy.frame(in: .global).height
            let maxHeight = height - 30
            return AnyView(
                ZStack {
                    BlurView(style: .systemThinMaterial)
                        .clipShape(CustomCorner(corners: [.topLeft, .topRight], radius: 20))
                        .edgesIgnoringSafeArea(.bottom)
                    if eventView {
                        VStack {
                            EventDetailsView(
                                event: $selectedEvent,
                                eventView: $eventView
                            )
                            .onAppear {
                                withAnimation {
                                    lastOffset = -maxHeight
                                    storedOffset = offset
                                    offset = -maxHeight
                                }
                                let coordinateRegion = MKCoordinateRegion(
                                    center: selectedEvent.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                                )
                                map.setRegion(coordinateRegion, animated: true)
                            }
                            .onDisappear {
                                withAnimation {
                                    offset = storedOffset
                                    lastOffset = offset
                                }
                            }
                            Spacer()
                        }
                    } else {
                        VStack {
                            Capsule()
                                .fill(.primary)
                                .frame(width: 60, height: 4)
                                .padding(.top, -5)

                            ScrollView {
                                ForEach(events.sorted { $0.slides.count > $1.slides.count }, id: \.name) { event in
                                    let eventBinding = Binding(
                                        get: { events.first(where: { $0.id == event.id })! },
                                        set: { newValue in
                                            if let index = events.firstIndex(where: { $0.id == newValue.id }) {
                                                events[index] = newValue
                                            }
                                        }
                                    )
                                    
                                    ListedEvent(event: eventBinding, selectedEvent: $selectedEvent, eventView: $eventView)
                                        .padding(.bottom)
                                }
                            }

                            Divider()
                                .background(.white)

                            Spacer()
                        }
                        .padding()
                    }
                } //: ZSTACK
                .offset(y: height - 30)
                .offset(y: -offset > 10 ? -offset <= maxHeight ? offset : -maxHeight : 0)
                .gesture(DragGesture().updating($gestureOffset, body: { value, out, _ in
                    out = value.translation.height
                    onChange()
                })
                .onEnded { _ in
                    withAnimation {
                        // Logic Conditions For Moving States....
                        // Up down or mid...
                        if (eventView && -offset > 30 && -offset < maxHeight / 3) || (eventView && -offset > maxHeight / 3) {
                            offset = -maxHeight
                        } else if -offset > 30, -offset < maxHeight / 3, offset < lastOffset {
                            // Mid...
                            offset = (-(maxHeight / 3) > -CGFloat(events.count * 120) + 20 || -(maxHeight / 3) < -CGFloat(events.count * 120) - 20) ? -CGFloat(events.count * 120) : -(maxHeight / 3)
                        } else if -offset > maxHeight / 3 {
                            offset = (events.count >= 7 || eventView) ? -maxHeight : -CGFloat(events.count * 120)
                        } else {
                            offset = 10
                        }
                    }

                    // Storing Last Offset...
                    // So that the gesture can continue from the last position....
                    lastOffset = offset
                })
            )
        }
    }

    func onChange() {
        DispatchQueue.main.async {
            self.offset = gestureOffset + lastOffset
        }
    }
}
