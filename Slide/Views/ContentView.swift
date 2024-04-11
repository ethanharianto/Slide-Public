//  ContentView.swift
//  Slide
//  Created by Ethan Harianto on 12/16/22.

import SwiftUI

struct ContentView: View {
    /*
     Each of these permissions are defined in the Classes/Permissions Folder. However, the User Listener is simply in the Classes Folder.
     */
    @ObservedObject var userListener = UserListener()
    @StateObject private var cameraPermission = CameraPermission()
    @StateObject private var locationPermission = LocationPermission()
    @StateObject private var contactsPermission = ContactsPermission()
    @StateObject private var notificationsPermission = NotificationPermission()
    @State private var userSignedUp = false


    var body: some View {
        /*
         Although there may be a better way to do this, I check each of the classes defined above for their published variables (user for the user listener and authorization status for the permissions). Depending on the published booleans, the view changes from account creation to location to contacts to camera to notification to the main view.
         */
        if userListener.user != nil {
            switch locationPermission.authorizationStatus {
                case .notDetermined:
                    LocationPermissionsView(locationPermission: locationPermission)

                default:
                    if contactsPermission.checkContactsPermission() == .notDetermined {
                        ContactsPermissionsView(contactsPermission: contactsPermission)
                    } else {
                        if cameraPermission.checkCameraPermission() == .notDetermined {
                            CameraPermissionsView(cameraPermission: cameraPermission)
                        } else {
                            if notificationsPermission.checkNotificationPermission() == .notDetermined {
                                NotificationPermissionsView(notificationsPermission: notificationsPermission)

                            } else {
                                MainView(isShowingTutorial: userSignedUp)
                            }
                        }
                    }
            }
        } else {
            AccountCreationView(userSignedUp: $userSignedUp)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
