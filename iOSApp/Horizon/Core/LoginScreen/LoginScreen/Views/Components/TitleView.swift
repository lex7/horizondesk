//  Created by Timofey Privalov on 18.01.2024.
import Foundation
import SwiftUI

struct TitleView: View {
    var body: some View {
        HStack {
            Image("NavBarLogo2")
                .resizable()
                .scaledToFit()
                .frame(height: 70)
        }
    }
}
