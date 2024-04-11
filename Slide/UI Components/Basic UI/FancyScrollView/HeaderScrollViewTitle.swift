import FirebaseAuth
import SwiftUI

struct HeaderScrollViewTitle: View {
    let title: String
    let titleColor: Color
    let height: CGFloat
    let largeTitle: Double
    var username = Auth.auth().currentUser?.displayName ?? "'"

    var body: some View {
        let largeTitleOpacity = (max(largeTitle, 0.5) - 0.5) * 2
        let tinyTitleOpacity = 1 - min(largeTitle, 0.5) * 2
        return ZStack {
            HStack {
                Text(title)
                    .font(.largeTitle)
                    .foregroundColor(titleColor)
                    .fontWeight(.black)
                    .padding(.horizontal, 16)

                Spacer()
            }
            .padding(.bottom, 8)
            .opacity(sqrt(largeTitleOpacity))
            .minimumScaleFactor(0.5)

            HStack {
                Text(username)
                    .font(.system(size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .padding(.bottom, (height - 18) / 2)
            .opacity(sqrt(tinyTitleOpacity))
        }.frame(height: height)
    }
}
