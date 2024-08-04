//  Created by Timofey Privalov MobileDesk
import SwiftUI

struct RootContentView: View {
    
    @EnvironmentObject private var authStateEnvObject: AuthStateEnvObject
    
    var body: some View {
        switch authStateEnvObject.authState {
        case .authorized:
            AppTabBarView()
        case .unauthorized, .onboarding:
            LoginScreen()
        case .forgotPassword:
            ForgotPasswordScreen()
        case .authorizedStatistic:
            ForgotPasswordScreen()
//            StatisticScreen()
        }
    }
}

#Preview {
    RootContentView()
}
