//
//  CameraPermissionsView.swift
//  Slide
//
//  Created by Ethan Harianto on 7/21/23.
//

import SwiftUI

struct CameraPermissionsView: View {
    @ObservedObject var cameraPermission = CameraPermission()
    
    var body: some View {
        ZStack {
            ProgressIndicator(numDone: 4)
            VStack (alignment: .center) {
                
                Image("camera_permission")
                    .resizable()
                    .frame(width: 160, height: 160)
                
                Text("Allow camera access?")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                Text("We use your camera in order to let you capture and share your best moments")
                    .frame(width: 350)
                    .multilineTextAlignment(.center)
                    
                Button {
                    cameraPermission.requestCameraPermission()
                } label: {
                    Text("Okay")
                        .filledBubble()
                }
                
                .padding()
            }
        }
    }
}


struct CameraPermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        CameraPermissionsView()
    }
}
