//  Created by Timofey Privalov on 31.01.2024.
import SwiftUI

struct AppTabBarView: View {
    
    // MARK: - Environment variables
    @EnvironmentObject private var authStateEnvObject: AuthStateEnvObject
    
    // MARK: - State variables
    @State private var selection: String = "home"
    
    // Access Level for Roles
    @State private var masterIsVisible: Bool = false
    
    // MARK: - Services
    private var credentialService = CredentialService.standard
    
    
    var body: some View {
        CustomTabBarContainer(selection: $authStateEnvObject.tabBarSelection) {
            CreateIssueScreen(tabSelection: $authStateEnvObject.tabBarSelection)
                .tabBarItem(tab: .createIssue, selection: $authStateEnvObject.tabBarSelection)
            MonitorIssueScreen(tabSelection: $authStateEnvObject.tabBarSelection)
                .tabBarItem(tab: .monitorIssue, selection: $authStateEnvObject.tabBarSelection)
            ExecutorScreen()
                .tabBarItem(tab: .executeIssue, selection: $authStateEnvObject.tabBarSelection)
            if masterIsVisible {
                MasterScreen(tabSelection: $authStateEnvObject.tabBarSelection)
                    .tabBarItem(tab: .masterReviewIssue, selection: $authStateEnvObject.tabBarSelection)
                
            }
            MyAccountScreen(tabSelection: $authStateEnvObject.tabBarSelection)
                .tabBarItem(tab: .account, selection: $authStateEnvObject.tabBarSelection)
        }
        .onAppear {
            if let role = credentialService.getUserRole() {
                guard let master = RoleEnum(rawValue: 2) else { return }
                if role == master.rawValue {
                    masterIsVisible = true
                } else {
                    masterIsVisible = false
                }
            }
        }
    }
}

struct AppTabBarView_Preview: PreviewProvider {
    static var previews: some View {
        AppTabBarView()
    }
}

extension AppTabBarView {
    func checkNotificationSettings(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }
}
