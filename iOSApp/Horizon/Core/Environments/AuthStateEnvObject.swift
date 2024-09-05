//  Created by Timofey Privalov on 20.02.2024.
import Foundation
import UIKit
import FirebaseMessaging
import Combine

protocol UIDataUpdatable {
    func updateAllData()
}

protocol DataClearable {
    func clearToken()
}

final class AuthStateEnvObject: ObservableObject {
    
    @Published var userDataModel: UserInfoDataModel?
    @Published var userRewardsDataModel: UserRewardsModel?
    @Published var requestsForMaster: [RequestIssueModel] = []
    @Published var requestsForMasterMonitor: [RequestIssueModel] = []
    @Published var issuesInWork: [RequestIssueModel] = []
    @Published var issuesDone: [RequestIssueModel] = []
    @Published var issuesDeclined: [RequestIssueModel] = []
    @Published var issuesApproved: [RequestIssueModel] = []
    @Published var issuesInProgress: [RequestIssueModel] = []
    @Published var logsModel: [LogsModel] = []
    @Published var notificationCount: Int = 0
    
    // MARK: - Private loaders
    @Published private(set) var masterIsLoading = false
    @Published private(set) var logsIsLoading = false
    // Auth data
    @Published var username: String = ""
    @Published var password: String = ""
    
    // MARK: - Published variables
    @Published private (set) var showProgress: Bool = false
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
    
    // MASTER SCREEN
    @Published var issueRequestSegment: IssuesMontitorSwitcher = .masterReview
    // MASTER SCREEN
    @Published var documentSegment: MasterSwitcher = .underMasterApproval
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
    
    
    func userLogin() {
        showProgress = true
        let token = credentialService.getFcm() ?? "EmptyFCM"
        let model = LoginModel(username: username, password: password, fcm_token: token)
        networkManager.requestMoyaData(apis: .login(model: model))
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ userLogin successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ userLogin]"))
                }
                self.showProgress = false
            } receiveValue: { [weak self] data in
                if let userModel = try? LoginData(data: data) {
                    guard let self = self else { return }
                    self.credentialService.saveUserId(userModel.user_id)
                    self.credentialService.saveUserRole(userModel.role_id)
                    self.tabBarSelection = .createIssue
                    debugPrint("USER ID: \(userModel.user_id) 🆔")
                    debugPrint("ROLE ID: \(userModel.role_id) 🏌️‍♂️")
                    self.authState = .authorized
                }
            }
            .store(in: &cancellables)
    }
    
    private func authorize(_ state: AuthState) {
        switch state {
        case .authorized:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [unowned self] in
                self.authState = .authorized
                self.isStatistic = true
            }
        case .authorizedStatistic:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [unowned self] in
                self.authState = .authorizedStatistic
                self.isStatistic = true
            }
        default:
            authState = .unauthorized
        }
    }
    
    
    func refreshUserToken(_ fcm: String, _ userId: Int ) {
        let model = RefreshUserFcmModel(user_id: userId, new_fcm: fcm)
        networkManager.requestMoyaData(apis: .refreshUserToken(model: model))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ refreshUserToken successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ refreshUserToken]"))
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    
    private func sendUserLogout(_ action: @escaping () -> Void) {
        guard let userId = credentialService.getUserId(),
              let fcm = credentialService.getFcm() else { return }
        let model = FcmOldModel(user_id: userId, old_fcm: fcm)
        networkManager.requestMoyaData(apis: .logout(model: model))
            .receive(on: DispatchQueue.main)
            .sink {completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ sendUserLogout successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ sendUserLogout]"))
                }
                action()
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
        
    // MARK: - Requests for Master
    func getRequestsForMaster() {
        if requestsForMaster.isEmpty {
            masterIsLoading = true
        }
        let model = UserIdModel(user_id: credentialService.getUserId() ?? 777)
        networkManager.requestMoyaData(apis: .underMasterApproval(model: model))
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ inProgressIssue successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ inProgressIssue]"))
                }
                self.masterIsLoading = false
            } receiveValue: { [unowned self] data in
                // self.issuesDone = array.filter { $0.statusOfElement == .done }.reversed()
                // po String(decoding: data, as: UTF8.self)
                do {
                    self.requestsForMaster = try RequestIssueModel.decode(from: data).sorted { ($0.created_at ?? Date()) > ($1.created_at ?? Date()) }
//                    debugPrint(requestsForMaster.count)
                } catch {
                    print(error)
                }
            }
            .store(in: &cancellables)
    }
    
    func getRequestsForMasterMonitor() {
        if requestsForMasterMonitor.isEmpty {
            masterIsLoading = true
        }
        let model = UserIdModel(user_id: credentialService.getUserId() ?? 777)
        networkManager.requestMoyaData(apis: .underMasterMonitor(model: model))
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ inProgressIssue successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ inProgressIssue]"))
                }
                self.masterIsLoading = false
            } receiveValue: { [unowned self] data in
                do {
                    self.requestsForMasterMonitor = try RequestIssueModel.decode(from: data).sorted { ($0.created_at ?? Date()) > ($1.created_at ?? Date()) }
                } catch {
                    print(error)
                }
            }
            .store(in: &cancellables)
    }
    
    func masterAcceptRequest(_ request_id: Int, _ reason: String, action: @escaping (()->Void)) {
        let model = MasterApproveModel(user_id: credentialService.getUserId() ?? 777,
                                       request_id: request_id,
                                       reason: reason)
        networkManager.requestMoyaData(apis: .masterApprove(model: model))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ MasterApproveModel successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ MasterApproveModel]"))
                }
            } receiveValue: { _ in
                action()
            }
            .store(in: &cancellables)
    }
    
    func masterDenyRequest(_ request_id: Int, _ reason: String, action: @escaping (()->Void)) {
        let model = MasterDenyModel(user_id: credentialService.getUserId() ?? 777,
                                    request_id: request_id,
                                    reason: reason)
        networkManager.requestMoyaData(apis: .masterDeny(model: model))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ masterDenyRequest successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ masterDenyRequest]"))
                }
            } receiveValue: { _ in
                action()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Executor Requests
    func executorUnassignRequest() {
        let model = UserIdModel(user_id: credentialService.getUserId() ?? 777)
        networkManager.requestMoyaData(apis: .executorUnassigned(model: model))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ executorUnassignRequest successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ executorUnassignRequest]"))
                }
            } receiveValue: { [unowned self] data in
                do {
                    self.issuesApproved = try RequestIssueModel.decode(from: data).sorted { ($0.updated_at ?? Date()) > ($1.updated_at ?? Date()) }
                } catch {
                    print(error)
                }
            }
            .store(in: &cancellables)
    }
    
    func executorMyTasksRequest() {
        let model = UserIdModel(user_id: credentialService.getUserId() ?? 777)
        networkManager.requestMoyaData(apis: .executorAssigned(model: model))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ executorMyTasksRequest successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ executorMyTasksRequest]"))
                }
            } receiveValue: { [unowned self] data in
                do {
                    self.issuesInProgress = try RequestIssueModel.decode(from: data).sorted { ($0.updated_at ?? Date()) > ($1.updated_at ?? Date()) }
                } catch {
                    print(error)
                }
            }
            .store(in: &cancellables)
    }

    func executerTakeOnWork(_ request_id: Int, action: @escaping ()->Void) {
        let model = ExecutorActionModel(user_id: credentialService.getUserId() ?? 777, request_id: request_id, reason: "")
        networkManager.requestMoyaData(apis: .takeOnWork(model: model))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ executerTakeOnWork successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ executerTakeOnWork]"))
                }
            } receiveValue: { _ in
                action()
            }
            .store(in: &cancellables)
    }
    
    func executerCancel(_ request_id: Int, reason: String = "", action: @escaping ()->Void) {
        let model = ExecutorCancelModel(user_id: credentialService.getUserId() ?? 777, request_id: request_id, reason: reason)
        networkManager.requestMoyaData(apis: .executerCancel(model: model))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ executerCancel successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ executerCancel]"))
                }
            } receiveValue: { _ in
                action()
            }
            .store(in: &cancellables)
    }
    
    func executerCompleteSendReview(_ request_id: Int, reason: String?, action: @escaping ()->Void) {
        let model = ExecutorActionModel(user_id: credentialService.getUserId() ?? 777, request_id: request_id, reason: reason)
        networkManager.requestMoyaData(apis: .executorComplete(model: model))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ executerCompleteSendReview successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ executerCompleteSendReview]"))
                }
            } receiveValue: { _ in
                action()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Creator of Requests:
    func getInProgressIssue() {
        let model = UserIdModel(user_id: credentialService.getUserId() ?? 777)
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
            } receiveValue: { [unowned self] data in
                do {
                    let arrayReview = try RequestIssueModel.decode(from: data).filter { $0.status_id == 5 }.sorted { ($0.updated_at ?? Date()) > ($1.updated_at ?? Date()) }
                    notificationCount = arrayReview.count
                    let restOfTasks = try RequestIssueModel.decode(from: data).filter { $0.status_id != 5 }.sorted { ($0.created_at ?? Date()) > ($1.created_at ?? Date()) }
                    self.issuesInWork = arrayReview + restOfTasks
                    debugPrint(issuesInWork.count)
                } catch {
                    print(error)
                }
            }
            .store(in: &cancellables)
    }
    
    func getCompletedIssue() {
        let model = UserIdModel(user_id: credentialService.getUserId() ?? 777)
        networkManager.requestMoyaData(apis: .completed(model: model))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ getCompletedIssue successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ getCompletedIssue]"))
                }
            } receiveValue: { [unowned self] data in
                // self.issuesDone = array.filter { $0.statusOfElement == .done }.reversed()
                // po String(decoding: data, as: UTF8.self)
                do {
                    self.issuesDone = try RequestIssueModel.decode(from: data).sorted { ($0.updated_at ?? Date()) > ($1.updated_at ?? Date()) }
                    debugPrint(issuesInWork.count)
                } catch {
                    debugPrint(error)
                }
            }
            .store(in: &cancellables)
    }
    
    func getDeniedIssue() {
        let model = UserIdModel(user_id: credentialService.getUserId() ?? 777)
        networkManager.requestMoyaData(apis: .denied(model: model))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ getDeniedIssue successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ getDeniedIssue]"))
                }
            } receiveValue: { [unowned self] data in
                // po String(decoding: data, as: UTF8.self)
                do {
                    self.issuesDeclined = try RequestIssueModel.decode(from: data).sorted { ($0.updated_at ?? Date()) > ($1.updated_at ?? Date()) }
                    debugPrint(issuesInWork.count)
                } catch {
                    print(error)
                }
            }
            .store(in: &cancellables)
    }
        
    func requestDone(request_id: Int, reason: String = "", action: @escaping (()->Void)) {
        var model = RequestDoneModel(user_id: 0, request_id: 0, reason: "")
        if !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            model = RequestDoneModel(user_id: credentialService.getUserId() ?? 777, request_id: request_id, reason: reason)
        } else {
            model = RequestDoneModel(user_id: credentialService.getUserId() ?? 777, request_id: request_id, reason: nil)
        }

        networkManager.requestMoyaData(apis: .requestorConfirm(model: model))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ requestDone successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ requestDone]"))
                }
            } receiveValue: { _ in
                action()
            }
            .store(in: &cancellables)
    }
    
    func requesterDeniedCompletion(request_id: Int, reason: String = "", action: @escaping (()->Void)) {
        var model = RequesterDeniedModel(user_id: 0, request_id: 0, reason: "")
        if !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            model = RequesterDeniedModel(user_id: credentialService.getUserId() ?? 777, request_id: request_id, reason: reason)
        } else {
            model = RequesterDeniedModel(user_id: credentialService.getUserId() ?? 777, request_id: request_id, reason: "")
        }
//        let model = RequesterDeniedModel(user_id: credentialService.getUserId() ?? 777, request_id: request_id, reason: clearReason)
        networkManager.requestMoyaData(apis: .requesterDeniedCompletion(model: model))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ requesterDeniedCompletion successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ requesterDeniedCompletion]"))
                }
            } receiveValue: { _ in
                action()
            }
            .store(in: &cancellables)
    }
    
    func requesterDeleteTask(request_id: Int, action: @escaping (()->Void)) {
        let model = RequestDeleteModel(user_id: credentialService.getUserId() ?? 777, request_id: request_id)
        networkManager.requestMoyaData(apis: .requesterDeleteTask(model: model))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ requesterDeleteTask successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ requesterDeleteTask]"))
                }
            } receiveValue: { _ in
                action()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - User data method
    func getUserInfoData() {
        let model = UserInfoModel(user_id: (credentialService.getUserId() ?? 777))
        networkManager.requestMoyaData(apis: .userData(model: model))
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ getUserInfoData successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ getUserInfoData]"))
                }
                self.getUserRewardsData()
            } receiveValue: { [unowned self] data in
                do {
                    self.userDataModel = try UserInfoDataModel(data: data)
                } catch (let error) {
                    debugPrint(error)
                }
            }
            .store(in: &cancellables)
    }
    
    private func getUserRewardsData() {
        let model = UserInfoModel(user_id: (credentialService.getUserId() ?? 777))
        networkManager.requestMoyaData(apis: .rewards(model: model))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ getUserRewardsData successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ getUserRewardsData]"))
                }
            } receiveValue: { [unowned self] data in
                do {
                    self.userRewardsDataModel = try UserRewardsModel(data: data)
                } catch (let error) {
                    debugPrint(error)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Task Logs
    func getLogs(_ request_id: Int) {
        let model = RequestIdModel(request_id: request_id)
        logsIsLoading = true
        networkManager.requestMoyaData(apis: .requestLogsOfTask(model: model))
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ getLogs successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ getLogs]"))
                }
                self.logsIsLoading = false
            } receiveValue: { [unowned self] data in
                do {
                    self.logsModel = try LogsModel.decode(from: data).sorted { $0.changed_at < $1.changed_at }
                    debugPrint(self.logsModel)
                } catch (let error) {
                    debugPrint(error)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Other Methods
    
    private func makeDateStamp() -> String {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd-MMM-yyyy'T'HH:mm'Z'"
        let timeCreate = outputFormatter.string(from: Date())
        return timeCreate
    }
    
    func logout(action: @escaping () -> ()) {
        isStatistic = false
        sendUserLogout {
            action()
        }
    }
    
    private func setVariables() {
        loadingInProgress = true
        errorToGetPermission = false
        errorDescription = ""
    }
}

extension AuthStateEnvObject: DataClearable {
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


extension AuthStateEnvObject: UIDataUpdatable {
    func updateAllData() {
        //
        Task {
            getInProgressIssue()
            getCompletedIssue()
            getDeniedIssue()
            // Master
            getRequestsForMaster()
            getRequestsForMasterMonitor()
            // Executor
            executorUnassignRequest()
            executorMyTasksRequest()
        }
    }
}


private extension AuthStateEnvObject {
    private func resetFirebaseFCMToken(completion: @escaping () -> Void) {
        completion()
        if let senderId = fcmTokenManager.getSenderId() {
            Messaging.messaging().deleteFCMToken(forSenderID: senderId, completion: { _ in
                Messaging.messaging().retrieveFCMToken(forSenderID: senderId, completion: { (token,error) in
                    if let error = error {
                        debugPrint(error)
                    }
                }
                )
            })
        }
    }
}

/*
user_id - add to other requests
position_id:
1 - рабочий
2 - мастер
3 - начальник
4 - босс
*/
