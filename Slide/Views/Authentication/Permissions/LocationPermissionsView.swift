//
//  SwiftUIView.swift
//  Slide
//
//  Created by Ethan Harianto on 7/16/23.
//

import SwiftUI
import CoreLocation

struct LocationPermissionsView: View {
    @ObservedObject var locationPermission = LocationPermission()
    
    var body: some View {
        ZStack {
            ProgressIndicator(numDone: 2)
            VStack (alignment: .center) {
                
                Image("location_permission")
                    .resizable()
                    .frame(width: 160, height: 160)
                
                Text("Allow location access?")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                Text("We use your location data in order to display nearby events")
                    .frame(width: 350)
                    .multilineTextAlignment(.center)
                    
                Button{ 
                    locationPermission.requestLocationPermission()
                } label: {
                    Text("Okay")
                        .filledBubble()
                }
                
                .padding()
            }
        }
    }
}


struct LocationPermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        LocationPermissionsView()
    }
}
