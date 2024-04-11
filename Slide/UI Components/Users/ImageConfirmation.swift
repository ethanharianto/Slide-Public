//  ImageConfirmation.swift
//  Slide
//  Created by Ethan Harianto on 8/7/23.

import FirebaseAuth
import PhotosUI
import SwiftUI

struct ImageConfirmation: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var selectedImage: UIImage? = UIImage()
    @State private var isShowingImagePicker = false
    @State private var user = Auth.auth().currentUser
    @State private var isPhotoLibraryAuthorized = false
    @State private var profilePictureURL: URL?
    @State private var confirm = false
    @Binding var reloadProfilePic: Bool
    
    var body: some View {
        VStack {
            HStack {
                Button { self.presentationMode.wrappedValue.dismiss() } label: {
                    Image(systemName: "chevron.left")
                }
                .padding(.leading)
                Spacer()
            }
            if selectedImage == UIImage() {
                UserProfilePictures(photoURL: user!.photoURL?.absoluteString ?? "", dimension: 150)
            } else {
                Image(uiImage: selectedImage!)
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 150, height: 150)
            }
            
            HStack {
                Button {
                    isShowingImagePicker = true
                } label: {
                    Text("Change Profile Picture")
                        .filledBubble()
                        .padding()
                }
                if confirm {
                    Button {
                        uploadProfilePicture()
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Confirm")
                            .filledBubble()
                            .padding()
                    }
                }
            }
            Spacer()
        }
        
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
                .onAppear {
                    checkPhotoLibraryPermission()
                    if !isPhotoLibraryAuthorized {
                        requestPhotoLibraryPermission()
                    }
                }
                .onDisappear {
                    if selectedImage != UIImage() {
                        confirm = true
                    }
                }
        }
    }
    
    func uploadProfilePicture() {
        let image = selectedImage
        guard let imageData = compressImageToTargetSize(image!, targetSizeInKB: 200) else {
            print("Failed to compress image.")
            return
        }
        let imageName = UUID().uuidString
        let storageRef = storageRef.child("profilePictures/\(imageName).jpg")
        
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading image to storage: \(error.localizedDescription)")
            } else {
                storageRef.downloadURL { url, error in
                    if let downloadURL = url {
                        profilePictureURL = downloadURL
                        updateProfilePictureURL()
                        updatePhotoURL(photoURL: profilePictureURL!) { _ in
                            reloadProfilePic.toggle()
                        }
                    } else if let error = error {
                        print("Error retrieving image download URL: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func updateProfilePictureURL() {
        guard let profilePictureURL = profilePictureURL else { return }
        
        let userRef = db.collection("Users").document(user!.uid)
        userRef.updateData(["ProfilePictureURL": profilePictureURL.absoluteString]) { error in
            if let error = error {
                print("Error updating user profile picture URL: \(error.localizedDescription)")
            }
        }
    }
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        isPhotoLibraryAuthorized = (status == .authorized)
    }

    func requestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                isPhotoLibraryAuthorized = (status == .authorized)
            }
        }
    }
    
    func updatePhotoURL(photoURL: URL, completion: @escaping (String?) -> Void) {
        let changeRequest = user!.createProfileChangeRequest()
        changeRequest.photoURL = photoURL
        changeRequest.commitChanges { error in
            if let error = error {
                completion("Error updating photo URL: \(error.localizedDescription)")
            } else {
                // Now the photoURL is updated, call the completion handler with the updated photo URL
                let userRef = db.collection("Users").document(user!.uid)
                userRef.updateData(["ProfilePictureURL": photoURL.absoluteString]) { error in
                    if let error = error {
                        print("Error updating photo URL in Firestore: \(error)")
                    }
                }
                completion(photoURL.absoluteString)
            }
        }
    }
}
