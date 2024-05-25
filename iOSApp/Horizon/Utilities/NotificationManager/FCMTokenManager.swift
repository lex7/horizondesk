//  Created by Timofey Privalov MobileDesk
import Foundation
import Combine

final class FCMTokenManager: ObservableObject {
    
    @Published var tokenSendToBackend: Bool = false
    
    // MARK: - Static
    static let shared = FCMTokenManager()
    
    private init() {}
    
    // MARK: - Private variables
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Private Constants
    
    private let networkManager = NetworkManager.standard
    private let credentialService = CredentialService.standard

    // FIXME: - use of assignFcmToken can be triggered twice.
    
    func assignFcmToken() {
        
    }
func getSenderId() -> String? {
        guard let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            debugPrint("Could not find GoogleService-Info.plist")
            return nil
        }
        let key = "GCM_SENDER_ID"
        let plist = NSDictionary(contentsOfFile: filePath)
        if let value = plist?.object(forKey: key) as? String {
            return value
        } else {
            debugPrint("Could not find value for key \(key) in GoogleService-Info.plist")
            return nil
        }
    }
}
