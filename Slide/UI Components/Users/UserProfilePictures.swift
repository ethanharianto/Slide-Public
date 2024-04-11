//
//  UserProfilePictures.swift
//  Slide
//
//  Created by Ethan Harianto on 7/27/23.
//

import Kingfisher
import SwiftUI

struct UserProfilePictures: View {
    let photoURL: String
    let dimension: CGFloat
    var body: some View {
        VStack {
            if photoURL.isEmpty {
                Image(systemName: "person.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: dimension, height: dimension)
                    .padding(5)
                    .clipShape(Circle())
            } else {
                KFImage(URL(string: photoURL)!)
                    .placeholder {
                        Image(systemName: "person.circle")
                    }
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .clipShape(Circle())
                    .frame(width: dimension, height: dimension)
                    .padding(5)
            }
        }
    }
}

struct UserProfilePictures_Previews: PreviewProvider {
    static var previews: some View {
        UserProfilePictures(photoURL: "https://static.foxnews.com/foxnews.com/content/uploads/2023/07/GettyImages-1495234870.jpg", dimension: 300)
    }
}
