//  Created by Timofey Privalov on 20.02.2024.
import Foundation
import UIKit
import FirebaseMessaging
import Combine



final class AuthStateEnvObject: ObservableObject {
    
    @Published var issueArray: [IssueModel] = []
    
    // new, approved, declined, inprogress, review, done
    
    @Published var issuesInWork: [IssueModel] = []
    @Published var issuesDone: [IssueModel] = []
    @Published var issuesDeclined: [IssueModel] = []
    @Published var issuesApproved: [IssueModel] = []
    @Published var issuesInProgress: [IssueModel] = []
    
    // Auth data
    @Published var username: String = ""
    @Published var password: String = ""
    
    // MARK: - Published variables
    @Published var authState: AuthState = .unauthorized
    @Published var isStatistic: Bool = false
    @Published var goingFromLogin: Bool = false
    @Published var permissionIsDownloaded: Bool = false
    
    // MARK: - Private Published variables
    @Published private(set) var loadingInProgress: Bool = false
    @Published var errorToGetPermission: Bool = false
    @Published private(set) var errorDescription = ""
    
    // TABBAR MENU
    @Published var tabBarSelection: TabBarItem = .createIssue
    
    // SUPPORT SCREEN
    // TRANSACTION SCREEN
    @Published var transactionSegment: TransactionSwitcher = .history
    // DEBT SCREEN
    @Published var issueDebtSegment: IssuesMontitorSwitcher = .inProgress
    // DOCUMENT SCREEN
    @Published var documentSegment: MasterSwitcher = .reviewTab
    // Application Version
    @Published var updateNeeded: Bool = false
    
    // MARK: - Private constants
    private var credentialService = CredentialService.standard
    private let fcmTokenManager = FCMTokenManager.shared
    private let networkManager = NetworkManager.standard
    
    // MARK: - private variables
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Static constants
    static let shared = AuthStateEnvObject()
    
    private init() {
        
    }
    
    func assignFcmHorizon() {
        if let id = credentialService.getUserRole(),
           let token = credentialService.getFcm() {
            let model = HorizonFcmModel(id: id, fcmToken: token)
            networkManager.requestMoyaData(apis: .assignFcmToken(model: model))
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        debugPrint(String(describing: "[vm: ✅ assignFcmHorizon successfully]"))
                        break
                    case .failure(let error):
                        debugPrint(String(describing: "[vm: \(error) - ❌ assignFcmHorizon]"))
                    }
                } receiveValue: { [weak self] _ in
                    
                }
                .store(in: &cancellables)
        }
    }
    
    func getIssues() {
        networkManager.requestMoyaData(apis: .getIssues)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ getIssues successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ getIssues]"))
                }
            } receiveValue: { [unowned self] data in
                if let array = try? JSONDecoder().decode([IssueModel].self, from: data) {
                    self.issueArray = array.reversed()
                    
                    self.issuesInWork = array.filter { $0.statusOfElement != .declined && $0.statusOfElement != .done }.reversed()
                    self.issuesDeclined = array.filter { $0.statusOfElement == .declined }.reversed()
                    self.issuesDone = array.filter { $0.statusOfElement == .done }.reversed()
                    self.issuesApproved = array.filter { $0.statusOfElement == .approved }.reversed()
                    self.issuesInProgress = array.filter { $0.statusOfElement == .inprogress }.reversed()
                }
            }
            .store(in: &cancellables)
    }
    
    func acceptIssue(id: String, action: @escaping (()->Void)) {
        let model = IssueAcceptModel(id: id, deadline: "")
        networkManager.requestMoyaData(apis: .acceptIssue(issue: model))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ acceptIssue successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ acceptIssue]"))
                }
            } receiveValue: { _ in
                action()
            }
            .store(in: &cancellables)
    }
    
    func declineIssue(id: String, action: @escaping (()->Void)) {
        let model = IssueDeclineModel(id: id, completed: "")
        networkManager.requestMoyaData(apis: .declineIssue(issue: model))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ declineIssue successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ declineIssue]"))
                }
            } receiveValue: { _ in
                action()
            }
            .store(in: &cancellables)
    }
    
    func inProgressIssue(id: String, action: @escaping (()->Void)) {
        let model = IssueIdModel(id: id)
        networkManager.requestMoyaData(apis: .inprogress(model: model))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ inProgressIssue successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ inProgressIssue]"))
                }
            } receiveValue: { _ in
                action()
            }
            .store(in: &cancellables)
    }
    
    func toReviewIssue(id: String, action: @escaping (()->Void)) {
        let model = IssueIdModel(id: id)
        networkManager.requestMoyaData(apis: .review(model: model))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ toReviewIssue successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ toReviewIssue]"))
                }
            } receiveValue: { _ in
                action()
            }
            .store(in: &cancellables)
    }
    
    func doneIssue(id: String, action: @escaping (()->Void)) {
        let model = IssueDoneModel(id: id, completed: makeDateStamp())
        networkManager.requestMoyaData(apis: .done(model: model))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ doneIssue successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ doneIssue]"))
                }
            } receiveValue: { _ in
                action()
            }
            .store(in: &cancellables)
    }
    
    private func makeDateStamp() -> String {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd-MMM-yyyy'T'HH:mm'Z'"
        let timeCreate = outputFormatter.string(from: Date())
        return timeCreate
    }
    
    func logout(action: @escaping () -> ()) {
        isStatistic = false
        action()
    }
    
    private func setVariables() {
        loadingInProgress = true
        errorToGetPermission = false
        errorDescription = ""
    }
}

extension AuthStateEnvObject {
    
    func clearToken() {
        resetFirebaseFCMToken { [weak self] in
            self?.permissionIsDownloaded  = false
            self?.tabBarSelection = .createIssue
            self?.credentialService.deleteToken()
            self?.credentialService.deleteUser()
            self?.credentialService.deleteUserId()
            self?.credentialService.deleteFcmToken()
            self?.credentialService.deleteUserRole()
            debugPrint("[AuthStateEnvObject: Token is cleared]")
        }
    }
}


private extension AuthStateEnvObject {
    
    private func resetFirebaseFCMToken(completion: @escaping () -> Void) {
        completion()
        if let senderId = fcmTokenManager.getSenderId() {
            Messaging.messaging().deleteFCMToken(forSenderID: senderId, completion: { [weak self] result in
                Messaging.messaging().retrieveFCMToken(forSenderID: senderId, completion: { (token,error) in
                    self?.fcmTokenManager.tokenSendToBackend = false
                    if let error = error {
                        debugPrint(error)
                    }
                }
                )
            })
        }
    }
}

extension AuthStateEnvObject {
    func checkPass() {
        credentialService.deleteUserRole()
        let validUsernames = ["TMK-328654", "TMK-328655", "TMK-328656"]
        let validPassword = "123456"
        
        if validUsernames.contains(username) && password == validPassword {
            if username == validUsernames[0] {
                tabBarSelection = .createIssue
                credentialService.saveUserRole("1")
            } else if username == validUsernames[1] {
                tabBarSelection = .executeIssue
                credentialService.saveUserRole("2")
            } else if username == validUsernames[2] {
                tabBarSelection = .reviewIssue
                credentialService.saveUserRole("3")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [unowned self] in
                self.authState = .authorized
                self.isStatistic = true
            }
        } else {
            authState = .unauthorized
        }
    }
}