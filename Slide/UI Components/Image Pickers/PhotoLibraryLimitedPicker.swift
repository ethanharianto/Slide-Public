import Photos
import SwiftUI

struct PhotoLibraryLimitedPicker: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedImage: UIImage?
    @State private var images: [UIImage] = [] // Store fetched images here

    var body: some View {
        VStack {
            Text("Select an image from the last 48 hours")
                .font(.headline)
                .padding()

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .onTapGesture {
                                selectedImage = image
                                presentationMode.wrappedValue.dismiss()
                            }
                    }
                }
                .padding()
            }

            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
        .onAppear {
            // Call the function and update the images when it completes
            fetchImagesFromLast48Hours { fetchedImages in
                images = fetchedImages
            }
        }
    }

    func fetchImagesFromLast48Hours(completion: @escaping ([UIImage]) -> Void) {
        var imagesToPick: [UIImage] = []

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        let currentDate = Date()
        let twoDaysAgo = Calendar.current.date(byAdding: .hour, value: -48, to: currentDate)!

        let group = DispatchGroup() // Create a dispatch group

        allPhotos.enumerateObjects { asset, _, _ in
            if asset.creationDate! > twoDaysAgo {
                group.enter() // Enter the dispatch group
                let options = PHImageRequestOptions()
                options.deliveryMode = .highQualityFormat
                PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: options) { image, _ in
                    if let image = image {
                        imagesToPick.append(image)
                    }
                    group.leave() // Leave the dispatch group when the request completes
                }
            }
        }

        group.notify(queue: .main) { // Notify when all requests are done
            print(imagesToPick.count)
            completion(imagesToPick) // Call the completion handler with the fetched images
        }
    }
}
