//
//  TutorialView.swift
//  Slide
//
//  Created by Thomas on 9/8/23.
//

import SwiftUI
import AVKit
import Firebase
import FirebaseStorage
import FirebaseFirestore


struct TutorialView: View {
    @Binding var isShowingTutorial: Bool
    @State var player: AVPlayer?

    var body: some View {
        TabView {
            Image("1")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.9)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2.3)

            Image("2")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.9)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2.3)

            Image("3")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.9)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2.3)

            Image("4")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.9)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2.3)

            ZStack {
                Image("5")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.9)
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2.3)
                
                VideoPlayer(player: player)
                    .onAppear {player!.play()}
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.8)
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)

            }
                
            Image("6")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.9)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2.3)
                

            Image("7")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.9)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2.3)

            Image("8")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.9)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2.3)
            
            ZStack {
                Image("9")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.9)
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2.3)
                
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            isShowingTutorial.toggle()
                        } label: {
                            Text("Exit")
                                .foregroundColor(.white)
                                .padding(3)
                                .background(Color.blue)
                                .cornerRadius(3)
                                .padding(.trailing, 20) // Adjust the trailing padding for horizontal positioning
                                .padding(.top, 0) // Add top padding to move it closer to the top
                        }
                    }
                    Spacer()
                }
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .onAppear {
            // Create a reference to the Firebase Storage URL
            let storageURL = URL(string: "gs://slide-1c356.appspot.com/TutorialImages/Posts.mov")

            // Download the video from Firebase Storage to a local URL
            let localURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Posts.mov")

            let storage = Storage.storage()
            let storageReference = storage.reference(forURL: storageURL!.absoluteString)

            let downloadTask = storageReference.write(toFile: localURL) { url, error in
                if let error = error {
                    print("Error downloading video: \(error)")
                } else {
                    // Video has been downloaded successfully, create AVPlayerItem
                    let playerItem = AVPlayerItem(url: localURL)

                    // Create an AVPlayer with the AVPlayerItem
                    var tempPlayer = AVPlayer(playerItem: playerItem)
                    tempPlayer.isMuted = true
                    tempPlayer.automaticallyWaitsToMinimizeStalling = false
                    // Now you can use the 'player' object to play the video
                    // Observe the AVPlayerItemDidPlayToEndTime notification
                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: nil) { _ in
                        // Seek the player back to the beginning
                        tempPlayer.seek(to: CMTime.zero)
                        // Start playing again
                        tempPlayer.play()
                    }
                    player = tempPlayer
                }
            }

            // You can observe the download progress using the downloadTask if needed

        }
    }
}
