import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI
import SwiftUI
import UIKit

struct PostCreationView: View {
    @State private var appearances = 0
    @Binding var source: UIImagePickerController.SourceType
    @State var isPhotoLibraryAuthorized = false
    @State private var image: UIImage?
    @State private var showImagePicker = false
    @State private var imageCaption = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedEvent: EventDisplay?
    @State private var eligibleEvents: [EventDisplay] = [EventDisplay(id: "", name: "fuck")]
    @State private var hasSelectedEvent: Bool = false

    var body: some View {
        VStack {
            Picker("Select an Event", selection: $selectedEvent) {
                Text("Select an Event")
                    .tag(nil as EventDisplay?) // Tag for the default value
                ForEach(eligibleEvents, id: \.id) { event in
                    Text(event.name).tag(event as EventDisplay?)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: selectedEvent, perform: { newValue in
                if let selectedEvent = newValue {
                    // Handle the selected event
                    withAnimation {
                        hasSelectedEvent = true // Update the hasSelected state
                    }
                } else {
                    withAnimation {
                        hasSelectedEvent = false // Update the hasSelected state
                    }
                }
            })
            if hasSelectedEvent {
                Image(uiImage: image ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
                    .padding()

                TextField("Caption", text: $imageCaption)
                    .checkMarkTextField()
                    .bubbleStyle(color: .primary)
                    .padding(.horizontal)

                Button {
                    appearances += 1
                    showImagePicker.toggle()
                } label: {
                    Text("Change Picture")
                        .filledBubble()
                        .padding(.horizontal)
                }

                Button(action: {
                    savePostToFirestore()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Submit")
                        .filledBubble()
                }
                .padding(.horizontal)
                .disabled(image == nil || image == UIImage()) // Disable the submit button when "Select Event" is selected
            }
        }
        .onAppear {
            checkPhotoLibraryPermission()
            if !isPhotoLibraryAuthorized {
                requestPhotoLibraryPermission()
            }
            showImagePicker.toggle()
            // Fetch eligible events when the view appears
            getEligibleEvents { events, error in
                if let events = events {
                    eligibleEvents = events
                } else {
                    // Handle the error here, if needed
                    print("Error fetching eligible events: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            if source == .camera {
                ImagePicker(sourceType: .camera, selectedImage: $image)
                    .onDisappear {
                        if image == nil && appearances == 0 {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
            } else {
                PhotoLibraryLimitedPicker(selectedImage: $image)
                    .onDisappear {
                        if image == nil && appearances == 0 {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
            }
        }
    }

    func fetchEligibleEvents() {
        getEligibleEvents { events, error in
            if let error = error {
                // Handle error if needed
                print("Error fetching eligible events: \(error.localizedDescription)")
            } else if let events = events {
                // Update the eligibleEvents property
                eligibleEvents = events
            }
        }
    }

    func savePostToFirestore() {
        guard let currentUser = Auth.auth().currentUser else {
            print("User not authenticated")
            return
        }
        guard let selectedEvent = selectedEvent else {
            print("No event selected")
            return
        }
        let postsCollection = db.collection("Posts")
        let postTime = Date()
        let postDocument: [String: Any] = [
            "User": currentUser.uid,
            "ImageCaption": imageCaption,
            "Likes": 0,
            "PostTime": postTime,
            "Event": selectedEvent.id // Save the selected event ID along with other post details
        ]
        let newPostDocument = postsCollection.document()
        // Save the post document to Firestore
        newPostDocument.setData(postDocument) { error in
            if let error = error {
                print("Error saving post to Firestore: \(error.localizedDescription)")
            } else {
                print("Post saved to Firestore successfully")
                // Upload the image to Firebase Storage
                uploadImageToFirebaseStorage(image: image ?? UIImage(), documentID: newPostDocument.documentID)
            }
            // Also have to add the post id to the events Associated Posts field.
            let postID = newPostDocument.documentID
            let eventID = selectedEvent.id
            let eventRef = db.collection("Events").document(eventID)
            eventRef.getDocument { document, _ in
                if let document = document, document.exists {
                    var associatedHighlights = document.data()?["Associated Highlights"] as? [String] ?? []
                    associatedHighlights.append(postID)
                    eventRef.updateData(["Associated Highlights": associatedHighlights])
                } else {
                    print("Event document not found!")
                }
            }
        }
    }

    func uploadImageToFirebaseStorage(image: UIImage, documentID: String) {
        guard let imageData = compressImageToTargetSize(image, targetSizeInKB: 200) else {
            print("Failed to compress image.")
            return
        }
        let storageRef = Storage.storage().reference().child("PostImages/\(documentID).jpg")
        let uploadTask = storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading image to Firebase Storage: \(error.localizedDescription)")
            } else {
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting download URL: \(error.localizedDescription)")
                    } else if let downloadURL = url {
                        // Update the post document with the image download URL
                        let db = Firestore.firestore()
                        let postDocumentRef = db.collection("Posts").document(documentID)
                        postDocumentRef.updateData(["PostImage": downloadURL.absoluteString]) { error in
                            if let error = error {
                                print("Error updating post document: \(error.localizedDescription)")
                            } else {
                                print("Post document updated successfully with image URL")
                            }
                        }
                    }
                }
            }
        }
        uploadTask.resume()
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
}

struct PostCreationView_Previews: PreviewProvider {
    static var previews: some View {
        PostCreationView(source: .constant(.photoLibrary))
    }
}

func compressImageToTargetSize(_ image: UIImage, targetSizeInKB: Int) -> Data? {
    let targetWidth: CGFloat = 1024 // Choose the desired width here
    let targetHeight = targetWidth * (image.size.height / image.size.width)
    let size = CGSize(width: targetWidth, height: targetHeight)

    UIGraphicsBeginImageContext(size)
    image.draw(in: CGRect(origin: .zero, size: size))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    // Check if the scaled image data is already below the target size
    if let scaledImageData = scaledImage?.jpegData(compressionQuality: 1.0) {
        let scaledSizeInKB = scaledImageData.count / 1024
        if scaledSizeInKB <= targetSizeInKB {
            return scaledImageData
        }
    }
    var compressionQuality: CGFloat = 1.0
    var imageData: Data?

    // Binary search to find the optimal compression quality
    var minQuality: CGFloat = 0.0
    var maxQuality: CGFloat = 1.0
    while minQuality <= maxQuality {
        compressionQuality = (minQuality + maxQuality) / 2.0
        if let compressedData = scaledImage?.jpegData(compressionQuality: compressionQuality) ?? image.jpegData(compressionQuality: compressionQuality) {
            let currentSizeInKB = compressedData.count / 1024
            if currentSizeInKB > targetSizeInKB {
                maxQuality = compressionQuality - 0.0001
            } else {
                imageData = compressedData
                minQuality = compressionQuality + 0.0001
            }
        } else {
            break
        }
    }

    return imageData
}
