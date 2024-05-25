//  Created by Timofey Privalov MobileDesk
import Foundation
import KeychainAccess
import Combine

final class CredentialService {
    
    // MARK: - Private Constants
    private let keychain = Keychain()
    private let lock = NSLock()

    // MARK: - Private Variables
    private var cancellables: Set<AnyCancellable> = []
    private var isRefreshing: Bool = false
    
    // MARK: - instance
    static let standard = CredentialService()
    
    // MARK: - LifeCycle
    private init() {}
    
    // MARK: - Public Methods
    func saveUserRole(_ user: String) {
        lock.lock()
        defer { lock.unlock() }
        keychain["_userRole"] = user
    }
func saveUser(_ user: String) {
        lock.lock()
        defer { lock.unlock() }
        keychain["_userName"] = user
    }
    
    func saveUserId(_ user: String) {
        keychain["_saveUserId"] = user
    }
    
    func getUserId() -> String? {
        return keychain["_saveUserId"]
    }
    
    func getUserRole() -> String? {
        return keychain["_userRole"]
    }
    
    func getUser() -> String? {
        return keychain["_userName"]
    }
    
    func saveFcm(_ fcm: String) {
        keychain["_MobileDeskFCM"] = fcm
    }
    
    func getFcm() -> String? {
        keychain["_MobileDeskFCM"]
    }

    func deleteToken() {
        do {
            try keychain.remove("_MobileDeskToken")
            debugPrint("JWT Token deleted ⭐️🔑❌")
        } catch (let error) {
            debugPrint(error.localizedDescription)
        }
    }

    func deleteFcmToken() {
        do {
            try keychain.remove("_MobileDeskFCM")
            debugPrint("FCM Token deleted ⭐️🔑❌")
        } catch (let error) {
            debugPrint(error.localizedDescription)
        }
    }
func deleteUser() {
        do {
            try keychain.remove("_userName")
            debugPrint("userName deleted ⭐️🔑❌")
        } catch (let error) {
            debugPrint(error.localizedDescription)
        }
    }
    
    func deleteUserId() {
        do {
            try keychain.remove("_saveUserId")
            debugPrint("UserId deleted ⭐️🔑❌")
        } catch (let error) {
            debugPrint(error.localizedDescription)
        }
    }
    
    func deleteUserRole() {
        do {
            try keychain.remove("_userRole")
            debugPrint("UserId deleted ⭐️🔑❌")
        } catch (let error) {
            debugPrint(error.localizedDescription)
        }
    }

    private func handleReceivedToken(data: Data, completion: @escaping (Result<String, Error>) -> ()) {

    }
}
