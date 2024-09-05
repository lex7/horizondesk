
import SwiftUI
import UserNotifications
import FirebaseCore
import FirebaseMessaging

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    // MARK: - Private constants
    private let credentialService = CredentialService.standard
    private let authStateEnvObject = AuthStateEnvObject.shared
    
    override init() {
        super.init()
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {  granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        })
        return true
    }
    
    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("Failed to register for remote notifications: \(error)")
    }

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var readableToken = ""
        for index in 0 ..< deviceToken.count {
            readableToken += String(format: "%02.2hhx", deviceToken[index] as CVarArg)
        }
        debugPrint("Received an APNs device token: \(readableToken)")
        Messaging.messaging().token { token, error in
            if let error {
                debugPrint("Error fetching FCM registration token: \(error)")
            } else if let token {
                debugPrint("FCM registration token 🔥: \(token)")
            }
        }
    }
func applicationDidBecomeActive(_ application: UIApplication) { }
func applicationWillResignActive(_ application: UIApplication) { }
}

extension AppDelegate: MessagingDelegate {
    @objc func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken {
            debugPrint("Firebase token FCM☀️🏁: \(String(describing: token))")
            credentialService.saveFcm(token)
            if let userId = credentialService.getUserId(),
               userId != 0 {
                authStateEnvObject.refreshUserToken(token, userId)
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        UIApplication.shared.applicationIconBadgeNumber = authStateEnvObject.notificationCount
        completionHandler([.banner, .sound, .badge, .list])
    }
    
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let pushPayload = response.notification.request.content.userInfo
        DispatchQueue.main.async { [unowned self] in
            authStateEnvObject.updateAllData()
        }
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler(.noData)
    }
}
