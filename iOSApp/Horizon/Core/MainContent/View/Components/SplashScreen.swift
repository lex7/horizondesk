//  Created by Timofey Privalov MobileDesk
import SwiftUI

struct SplashScreen: View {
    
    var body: some View {
        VStack {
            Spacer()
            Image("NavBarLogo2") // AngLogo
                .resizable()
                .scaledToFit()
                .frame(height: 126)
            Spacer()
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    SplashScreen()
}
