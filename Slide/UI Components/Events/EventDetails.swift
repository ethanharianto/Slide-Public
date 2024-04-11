//  EventDetails.swift
//  Slide
//  Created by Vaishnav Garodia on 8/8/23.

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Foundation
import SwiftUI
import UIKit

struct EventDetails: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var image: UIImage = .init()
    var event: Event
    var preview = false
    var fromMap = true
    @Binding var eventView: Bool
    @State private var profileView = false
    @State private var selectedUser: UserData? = nil
    @State private var isRSVPed = false
    @State private var isLoading = false
    @State private var username = ""
    @State private var photoURL = ""
    @State private var showDescription = false
    @State private var friendSlides: [String] = []
    @State private var nonFriendSlides: [String] = []
    @State private var showEventEditSheet = false
    @State private var bannerImage: UIImage = .init()
    @State var showEditButton: Bool
    @StateObject var notificationPermission = NotificationPermission()


    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                // Display event details here based on the 'event' parameter
                // For example:
                HStack {
                    if !fromMap {
                        Button {
                            self.presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "chevron.left.circle")
                                .imageScale(.large)
                                .padding(.leading)
                        }
                    } else {
                        Button {
                            withAnimation {
                                eventView.toggle()
                            }
                        } label: {
                            Image(systemName: "chevron.left.circle")
                                .imageScale(.large)
                                .padding(.leading)
                        }
                    }
                    Spacer()
                    if !event.bannerURL.isEmpty || image != UIImage() {
                        Image(systemName: event.icon)
                            .imageScale(.large)
                    }

                    Text(event.name)
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    if showEditButton && event.hostUID == Auth.auth().currentUser!.uid && event.start > Date() {
                        // Then display the edit button
                        Button(action: {
                            showEventEditSheet.toggle()
                        }) {
                            Image(systemName: "pencil")
                                .imageScale(.large)
                                .padding(.trailing)
                        }
                    } else {
                        UserProfilePictures(photoURL: photoURL, dimension: 35)
                            .padding(.trailing)
                            .onTapGesture {
                                if username != Auth.auth().currentUser?.displayName && !preview {
                                    selectedUser = UserData(userID: event.hostUID, username: username, photoURL: photoURL)
                                    profileView.toggle()
                                }
                            }
                    }
                }
                .padding()

                Group { // EventBanner
                    Capsule()
                        .frame(width: UIScreen.main.bounds.width * 0.85, height: 3)
                        .foregroundColor(.primary)
                    ZStack {
                        if !event.bannerURL.isEmpty {
                            EventBanner(imageURL: URL(string: event.bannerURL)!)
                                .cornerRadius(15)
                                .padding()
                        } else if image != UIImage() {
                            Image(uiImage: image)

                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width * 0.95, height: UIScreen.main.bounds.width * 0.95 * 3 / 4)
                                .cornerRadius(15)
                                .padding()
                        } else {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(LinearGradient(colors: [.accentColor, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: UIScreen.main.bounds.width * 0.95, height: UIScreen.main.bounds.width * 0.95 * 3 / 4)
                            Image(systemName: event.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width * 0.15, height: UIScreen.main.bounds.width * 0.15)
                        }
                    }
                    .shadow(radius: 15)

                    Capsule()
                        .frame(width: UIScreen.main.bounds.width * 0.85, height: 3)
                        .foregroundColor(.primary)
                }
                VStack {
                    Text(formatDate(date: event.start) + " - " + formatDate(date: event.end))
                        .font(.callout)

                    HStack {
                        Image(systemName: "mappin")
                        Text(event.address)
                            .font(.callout)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        withAnimation {
                            showDescription.toggle()
                        }
                    } label: {
                        Text(showDescription ? "Hide Description" : "Show Description").font(.caption).foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }

                    if showDescription {
                        Text(event.eventDescription)
                            .font(.caption)
                    }
                }
                .padding()

                ScrollView(.horizontal) {
                    HStack(spacing: 16) { // Adjust spacing as needed
                        ForEach(friendSlides, id: \.self) { friendID in
                            UserSlidedProfileBox(uid: friendID, friend: true, profileView: $profileView, selectedUser: $selectedUser)
                        }
                        ForEach(nonFriendSlides, id: \.self) { nonFriendID in
                            UserSlidedProfileBox(uid: nonFriendID, friend: false, profileView: $profileView, selectedUser: $selectedUser)
                        }
                    }
                    .padding(.horizontal) // Add some padding to the HStack
                }

                if event.hostUID != Auth.auth().currentUser!.uid && !preview {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            BackgroundComponent()
                            DraggingComponent(isRSVPed: $isRSVPed, isLoading: isLoading, maxWidth: geometry.size.width)
                        }
                    }
                    .frame(height: 50)
                    .padding()
                    .onChange(of: isRSVPed) { _ in
                        print("we out here")
                        simulateRequest()
                    }
                }
            }
        }
        .padding()
        .scrollIndicators(.never)
        .onAppear {
            isRSVPed = event.slides.contains(Auth.auth().currentUser?.uid ?? "")
            if !preview {
                extractFriendSlides(event: event) { friendSlidesTemp, nonFriendSlidesTemp in
                    self.friendSlides = friendSlidesTemp
                    self.nonFriendSlides = nonFriendSlidesTemp
                }
                fetchUsernameAndPhotoURL(for: event.hostUID) { temp, temp2 in
                    username = temp!
                    photoURL = temp2!
                }
            } else {
                username = (Auth.auth().currentUser?.displayName)!
                photoURL = Auth.auth().currentUser?.photoURL?.absoluteString ?? ""
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showEventEditSheet) {
            EventEditView(showEventEditSheet: $showEventEditSheet, event: event, destination: event.coordinate)
        }
        .fullScreenCover(isPresented: $profileView) {
            UserProfileView(user: $selectedUser)
        }
    }
    
    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, h:mm a"
        return dateFormatter.string(from: date)
    }

    private func simulateRequest() {
        isLoading = true
        let userID = Auth.auth().currentUser!.uid
        let eventID = event.id
        let eventDoc = db.collection("Events").document(eventID)
        let userDoc = db.collection("Users").document(userID)

        var needsNoti = true

        // Update user's SLIDES array
        userDoc.getDocument { userDocument, error in
            if let error = error {
                print("Error getting user document: \(error)")
                return
            }

            var slidesArray: [String] = []

            if let userData = userDocument?.data(),
               let existingSlides = userData["SLIDES"] as? [String]
            {
                slidesArray = existingSlides
            }

            if slidesArray.contains(eventID) {
                slidesArray.removeAll { $0 == eventID }
                needsNoti = false

            } else {
                slidesArray.append(eventID)
                needsNoti = true
            }
            userDoc.setData(["SLIDES": slidesArray], merge: true) { error in
                if let error = error {
                    print("Error updating user document: \(error)")
                }
            }
        }

        // Update event's SLIDES array
        eventDoc.getDocument { eventDocument, error in
            if let error = error {
                print("Error getting event document: \(error)")
                return
            }

            var slidesArray: [String] = []

            if let eventData = eventDocument?.data(),
               let existingSlides = eventData["SLIDES"] as? [String]
            {
                slidesArray = existingSlides
            }

            if slidesArray.contains(userID) {
                slidesArray.removeAll { $0 == userID }
            } else {
                slidesArray.append(userID)
            }

            eventDoc.setData(["SLIDES": slidesArray], merge: true) { error in
                if let error = error {
                    print("Error updating user document: \(error)")
                }
            }

            if needsNoti,
               let eventData = eventDocument?.data()
            {
                let name = eventData["Name"] as? String ?? ""
//                let description = eventData["Description"] as? String ?? ""
                let eventID = eventDocument!.documentID
                if let start = (eventData["Start"] as? Timestamp)?.dateValue() {
                    let identifier = eventID + "|" + userID
                    let title = "Starting Soon!"
                    let body = name + " is starting soon"

                    let notificationCenter = UNUserNotificationCenter.current()
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = body
                    content.sound = .default

                    let calendar = Calendar.current
                    let start20 = calendar.date(byAdding: .minute, value: -20, to: start)
                    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: start20!)
                    let year = components.year
                    let month = components.month
                    let day = components.day
                    let hour = components.hour
                    let minute = components.minute

                    var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)

                    dateComponents.year = year
                    dateComponents.month = month
                    dateComponents.day = day
                    dateComponents.hour = hour
                    dateComponents.minute = minute

                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

//                    you might think you're being clean, but do us all a favor and don't delete this
//                    notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
                    notificationCenter.add(request)
                }
            }
            if needsNoti && notificationPermission.isNotificationPermission,
//            if needsNoti,
               let eventData = eventDocument?.data() {
                let name = eventData["Name"] as? String ?? ""
//                let description = eventData["Description"] as? String ?? ""
                let eventID = eventDocument!.documentID
                if let start = (eventData["Start"] as? Timestamp)?.dateValue() {
                    let identifier = "Event|" + eventID + "|" + userID
                    let title = "Starting Soon!"
                    let body = "An event you slid into is starting soon"
                    let identifier2 = "Post|" + eventID + "|" + userID
                    let title2 = "Time to make your post!"
                    let body2 = "Make your post for " + name
                    
                    let notificationCenter = UNUserNotificationCenter.current()
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = body
                    content.sound = .default
                    let content2 = UNMutableNotificationContent()
                    content2.title = title2
                    content2.body = body2
                    content2.sound = .default
                    
                    
                    let calendar = Calendar.current
                    let start20 = calendar.date(byAdding: .minute, value: -20, to: start)
                    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: start20!)
                    let year = components.year
                    let month = components.month
                    let day = components.day
                    let hour = components.hour
                    let minute = components.minute

                    var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
                    
                    dateComponents.year = year
                    dateComponents.month = month
                    dateComponents.day = day
                    dateComponents.hour = hour
                    dateComponents.minute = minute
                                        
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                    
//                    you might think you're being clean, but do us all a favor and don't delete this
                    notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
                    notificationCenter.add(request)
                    
                    // If end wasn't specified set it to 3 hours after the start
                    let end = (eventData["End"] as? Timestamp)?.dateValue() ?? Calendar.current.date(byAdding: .hour, value: 3, to: start)!
                    // Calculate the time interval between date1 and date2
                    let duration = end.timeIntervalSince(start)

                    // Calculate a Date that is 1/5th of the way between date1 and date2
                    let oneFifthDuration = duration / 5
                    let oneFifthDate = start.addingTimeInterval(oneFifthDuration)
                    
                    // Calculate a Date that is exactly 1/2 of the way between date1 and date2
                    let halfDuration = duration / 2
                    let halfwayDate = start.addingTimeInterval(halfDuration)
                    
                    let postReminderDate = randomDateBetween(start: oneFifthDate, end: halfwayDate)

                    let postReminderDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: postReminderDate)
                    let postYear = postReminderDateComponents.year
                    let postMonth = postReminderDateComponents.month
                    let postDay = postReminderDateComponents.day
                    let postHour = postReminderDateComponents.hour
                    let postMinute = postReminderDateComponents.minute

                    var dateComponentsPostReminder = DateComponents(calendar: Calendar.current, timeZone: TimeZone.current)
                    
                    dateComponentsPostReminder.year = postYear
                    dateComponentsPostReminder.month = postMonth
                    dateComponentsPostReminder.day = postDay
                    dateComponentsPostReminder.hour = postHour
                    dateComponentsPostReminder.minute = postMinute

                    let trigger2 = UNCalendarNotificationTrigger(dateMatching: dateComponentsPostReminder, repeats: false)
                    let request2 = UNNotificationRequest(identifier: identifier2, content: content2, trigger: trigger2)
                    
//                    you might think you're being clean, but do us all a favor and don't delete this
                    notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier2])
                    notificationCenter.add(request2)
                }
            }
        }
        
        isLoading = false
    }
}

