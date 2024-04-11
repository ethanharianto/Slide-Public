//  UserSearchResults.swift
//  Slide
//  Created by Ethan Harianto on 7/30/23.

import SwiftUI

struct UserSearchResults: View {
    @Binding var searchResults: [UserData]

    var body: some View {
        ForEach(searchResults, id: \.userID) { friend in
            SearchResult(user: friend)
        }

    }
}

struct UserSearchResults_Previews: PreviewProvider {
    static var previews: some View {
        UserSearchResults(searchResults: .constant([UserData(userID: "mwahah", username: "baesuzy", photoURL: "https://m.media-amazon.com/images/M/MV5BZWQ5YTFhZDAtMTg3Yi00NzIzLWIyY2EtNDQ2YWNjOWJkZWQxXkEyXkFqcGdeQXVyMjQ2OTU4Mjg@._V1_.jpg", added: false), UserData(userID: "mwahahah", username: "tomholland", photoURL: "https://static.foxnews.com/foxnews.com/content/uploads/2023/07/GettyImages-1495234870.jpg", added: false)]))
    }
}
