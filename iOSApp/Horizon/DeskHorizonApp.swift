
//
//  Created by Timofey Privalov MobileDesk
import SwiftUI

@main
struct DeskHorizonApp: App {
    // MARK: - AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // MARK: - StateObjects
    @StateObject var authStateEnvObject = AuthStateEnvObject.shared
    
    var body: some Scene {
        WindowGroup {
            RootContentView()
                .environmentObject(authStateEnvObject)
                .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
