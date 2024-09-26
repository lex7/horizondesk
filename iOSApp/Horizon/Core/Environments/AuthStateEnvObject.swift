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
    @Published var issuesFilteredBoss: [RequestIssueModel] = []
    @Published var logsModel: [LogsModel] = []
    @Published var notificationCount: Int = 0
    
    // MARK: - Private loaders
    @Published private(set) var masterIsLoading = false
    @Published private(set) var logsIsLoading = false
    @Published private(set) var statsIsLoading = false
    @Published private(set) var getInProgressIssueLoading = false
    
    
    // Auth data
    @Published var username: String = ""
    @Published var password: String = ""
    
    // MARK: - Published variables
    @Published private (set) var showProgress: Bool = false
    @Published private (set) var isErrorCodeLogin: String = ""
    @Published var isErrorLogin: Bool = false
    @Published var authState: AuthState = .unauthorized
    @Published var isStatistic: Bool = false
    @Published var goingFromLogin: Bool = false
    @Published var permissionIsDownloaded: Bool = false
    @Published var isMasterErrorTakeRequest: Bool = false
    
    // MARK: - Private Published variables
    @Published private(set) var loadingInProgress: Bool = false
    @Published var errorToGetPermission: Bool = false
    @Published private(set) var errorDescription = ""
    
    // TABBAR MENU
    @Published var tabBarSelection: TabBarItem = .createIssue
    
    // Average Stats
    @Published var scrollPositionStart: Date = Date()
    @Published var allStatsFragments: [(day: Date, events: Int)] = []
    
    // Filtered Stats
    @Published var filteredChartFragments: [(day: Date, events: Int)] = []
    @Published var filteredSpecialFragments: [(name: String, sales: Int)] = []
    @Published var filteredStatusFragments: [(name: String, sales: Int)] = []
    
    @Published var filtereScrollPositionStart: Date = Date()
    @Published var visibleDomain: Int = 30
    @Published var filteredIsLoading: Bool = false
    @Published var isPresentFiltered: Bool = false
    @Published var showAlertOfFilter: Bool = false
    
    // USER Rating Filtered Stats
    @Published var usersRating: [UserRatingModel] = []
    
    // MASTER SCREEN
    @Published var issueRequestSegment: IssuesMontitorSwitcher = .masterReview
    // MASTER SCREEN
    @Published var documentSegment: MasterSwitcher = .underMasterApproval
    // Application Version
    @Published var updateNeeded: Bool = false
    // masterAproveInWork
    @Published var masterAproveInWork: Bool = false
    @Published var isExecuterTakeOnWork: Bool = false
    @Published var isRequesterDeniedProgress: Bool = false
    // MARK: - Private constants
    private var credentialService = CredentialService.standard
    private let fcmTokenManager = FCMTokenManager.shared
    private let networkManager = NetworkManager.standard
    
    // MARK: - private variables
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Static constants
    static let shared = AuthStateEnvObject()
      
    private init() {
        if let status = credentialService.getAuthStatus() {
            if status == "authorized" {
                authState = .authorized
                if isManager() {
                    tabBarSelection = .manager
                }
            }
        }
    }
    
    private func isManager() -> Bool {
        if let role = credentialService.getUserRole() {
            if role == 3 {
                return true
            }
        }
        return false
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
                    isErrorCodeLogin = error.localizedDescription
                    isErrorLogin = true
                }
                self.showProgress = false
            } receiveValue: { [weak self] data in
                if let userModel = try? LoginData(data: data) {
                    guard let self = self else { return }
                    self.credentialService.saveUserId(userModel.user_id)
                    self.credentialService.saveUserRole(userModel.role_id)
                    self.credentialService.saveAuthToken(userModel.access_token)
                    self.tabBarSelection = .createIssue
                    debugPrint("USER ID: \(userModel.user_id) 🆔")
                    debugPrint("ROLE ID: \(userModel.role_id) 🏌️‍♂️")
                    self.credentialService.saveAuthStatus("authorized")
                    self.authState = .authorized
                    if isManager() {
                        tabBarSelection = .manager
                    }
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
        clearDateLogOut()
        guard let userId = credentialService.getUserId(),
              let fcm = credentialService.getFcm() else {
            action()
            return
        }
        action()
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
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
        
    // MARK: - Requests for Master
    func getRequestsForMaster() {
        if isManager() {
            return
        }
        if requestsForMaster.isEmpty {
            masterIsLoading = true
        }
        let model = UserIdModel(user_id: credentialService.getUserId() ?? 777)
        networkManager.requestMoyaData(apis: .underMasterApproval(model: model))
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ getRequestsForMaster successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ getRequestsForMaster]"))
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
                    debugPrint(String(describing: "[vm: ✅ getRequestsForMasterMonitor successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ getRequestsForMasterMonitor]"))
                }
                self.masterIsLoading = false
            } receiveValue: { [unowned self] data in
                do {
                    self.requestsForMasterMonitor = try RequestIssueModel.decode(from: data).sorted { ($0.created_at ?? Date()) > ($1.created_at ?? Date()) }
                    //debugPrint(self.requestsForMasterMonitor)
                } catch {
                    print(error)
                }
            }
            .store(in: &cancellables)
    }
    
    func masterAcceptRequest(_ request_id: Int, _ reason: String, action: @escaping (()->Void)) {
        masterAproveInWork = true
        let model = MasterApproveModel(user_id: credentialService.getUserId() ?? 777,
                                       request_id: request_id,
                                       reason: reason)
        networkManager.requestMoyaData(apis: .masterApprove(model: model))
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ MasterApproveModel successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ MasterApproveModel]"))
                }
                self.masterAproveInWork = false
            } receiveValue: { _ in
                action()
            }
            .store(in: &cancellables)
    }
    
    func masterDenyRequest(_ request_id: Int, _ reason: String, action: @escaping (()->Void)) {
        masterAproveInWork = true
        let model = MasterDenyModel(user_id: credentialService.getUserId() ?? 777,
                                    request_id: request_id,
                                    reason: reason)
        networkManager.requestMoyaData(apis: .masterDeny(model: model))
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ masterDenyRequest successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ masterDenyRequest]"))
                }
                self.masterAproveInWork = false
            } receiveValue: { _ in
                action()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Executor Requests
    func executorUnassignRequest() {
        if isManager() {
            return
        }
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
        if isManager() {
            return
        }
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
        isExecuterTakeOnWork = true
        let model = ExecutorActionModel(user_id: credentialService.getUserId() ?? 777, request_id: request_id, reason: "")
        networkManager.requestMoyaData(apis: .takeOnWork(model: model))
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ executerTakeOnWork successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ executerTakeOnWork]"))
                    if error.localizedDescription.contains("400") {
                        self.isMasterErrorTakeRequest = true
                    }
                }
                self.isExecuterTakeOnWork = false
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
        getInProgressIssueLoading = true
        if isManager() {
            return
        }
        let model = UserIdModel(user_id: credentialService.getUserId() ?? 777)
        networkManager.requestMoyaData(apis: .inprogress(model: model))
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ inProgressIssue successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ inProgressIssue]"))
                }
                self.getInProgressIssueLoading = false
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
        if isManager() { return }
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
        if isManager() { return }
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
        isRequesterDeniedProgress = true
        var model = RequestDoneModel(user_id: 0, request_id: 0, reason: "")
        if !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            model = RequestDoneModel(user_id: credentialService.getUserId() ?? 777, request_id: request_id, reason: reason)
        } else {
            model = RequestDoneModel(user_id: credentialService.getUserId() ?? 777, request_id: request_id, reason: nil)
        }

        networkManager.requestMoyaData(apis: .requestorConfirm(model: model))
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ requestDone successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ requestDone]"))
                }
                self.isRequesterDeniedProgress = false
            } receiveValue: { _ in
                action()
            }
            .store(in: &cancellables)
    }
    
    func requesterDeniedCompletion(request_id: Int, reason: String = "", action: @escaping (()->Void)) {
        isRequesterDeniedProgress = true
        var model = RequesterDeniedModel(user_id: 0, request_id: 0, reason: "")
        if !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            model = RequesterDeniedModel(user_id: credentialService.getUserId() ?? 777, request_id: request_id, reason: reason)
        } else {
            model = RequesterDeniedModel(user_id: credentialService.getUserId() ?? 777, request_id: request_id, reason: "")
        }
//        let model = RequesterDeniedModel(user_id: credentialService.getUserId() ?? 777, request_id: request_id, reason: clearReason)
        networkManager.requestMoyaData(apis: .requesterDeniedCompletion(model: model))
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ requesterDeniedCompletion successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ requesterDeniedCompletion]"))
                }
                self.isRequesterDeniedProgress = false
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
            } receiveValue: { [unowned self] data in
                do {
                    self.userDataModel = try UserInfoDataModel(data: data)
                } catch (let error) {
                    debugPrint(error)
                }
            }
            .store(in: &cancellables)
    }
    
    func getUserRewardsData() {
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
                    // po String(decoding: data, as: UTF8.self)
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
    
    // MARK: - Requests by filter
    func filterRequests(_ model: BossFilterModel) {
        filteredIsLoading = true
        networkManager.requestMoyaData(apis: .bossRequests(model: model))
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ filterRequests successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ filterRequests]"))
                }
                self.filteredIsLoading = false
            } receiveValue: { [unowned self] data in
                do {
                    self.issuesFilteredBoss = try RequestIssueModel.decode(from: data).sorted { ($0.created_at ?? Date()) > ($1.created_at ?? Date()) }
                    let fragmentModels = createFragmentModels(from: issuesFilteredBoss).sorted { makeDateFrom($0.date) < makeDateFrom($1.date) }
                    self.filteredChartFragments = fragmentModels.map { (day: makeDateFrom($0.date), events: $0.events) }
                    if let last = self.filteredChartFragments.last {
                        self.filtereScrollPositionStart = last.day.addingTimeInterval(-1 * 3600 * 24 * 31)
                        Task {
                            try await Task.sleep(nanoseconds: 50_000_000) // Sleep on a background thread
                            await MainActor.run {
                                self.filtereScrollPositionStart = last.day.addingTimeInterval(-1 * 3600 * 24 * 30)
                            }
                        }
                        self.isPresentFiltered = true
                    } else {
                        self.showAlertOfFilter = true
                    }
                    
                    let firstDate = fragmentModels.first?.date.makeDateFrom()
                    let lastDate = fragmentModels.last?.date.makeDateFrom()
                    let daysDifferentBetweenRequests = getDaysDifferent(firstDate, lastDate)
                    
                    if daysDifferentBetweenRequests >= 30 {
                        self.visibleDomain = 30
                    } else if daysDifferentBetweenRequests > 14 {
                        self.visibleDomain = 14
                    } else if daysDifferentBetweenRequests >= 7 {
                        self.visibleDomain = 7
                    } else if daysDifferentBetweenRequests >= 3 {
                        self.visibleDomain = 3
                    } else if daysDifferentBetweenRequests == 2 {
                        self.visibleDomain = 2
                    } else {
                        self.visibleDomain = 1
                    }
                    // po String(decoding: data, as: UTF8.self)
                } catch {
                    print(error)
                }
            }
            .store(in: &cancellables)
    }
    
    private func createFragmentModels(from requestModels: [RequestIssueModel]) -> [FragmentModel] {
        let grouped = Dictionary(grouping: requestModels, by: { model -> String in
            if let createdAt = model.created_at {
                return dateString(from: createdAt)
            } else {
                return "Unknown date"
            }
        })
        return grouped.map { (key, value) in
            FragmentModel(date: key, events: value.count)
        }.sorted(by: { $0.date > $1.date }) // Sorted descending by date
    }
    
    private func dateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func getDaysDifferent(_ firstDate: Date?, _ lastDate: Date?) -> Int {
        // Check if either date is nil
        if let startDate = firstDate, let endDate = lastDate {
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.day], from: startDate, to: endDate)
            if let days = dateComponents.day {
                return days
            }
        }
        return 0
    }

    func getAllStats() {
        statsIsLoading = true
        networkManager.requestMoyaData(apis: .getAllStats)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ getAllStats successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ getAllStats]"))
                }
                self.statsIsLoading = false
            } receiveValue: { [unowned self] data in
                do {
                    let dataArray = try FragmentModel.decodeFrom(data: data)
                    debugPrint("OK")
                    self.allStatsFragments = dataArray.map { (day: makeDateFrom($0.date),
                                                              events: $0.events) }.sorted { $0.day > $1.day }
                    if let last = self.allStatsFragments.last {
                        self.scrollPositionStart = last.day.addingTimeInterval(-1 * 3600 * 24 * 31)
                        Task {
                            try await Task.sleep(nanoseconds: 100_000_000) // Sleep on a background thread
                            await MainActor.run {
                                self.scrollPositionStart = last.day.addingTimeInterval(-1 * 3600 * 24 * 30)
                            }
                        }
                    } else {
                        debugPrint("No Last")
                    }
                } catch (let error) {
                    debugPrint(error)
                }
            }
            .store(in: &cancellables)
    }
    
    func makeSortingName(_ up: Bool) {
        if up {
            usersRating = usersRating.sorted { $0.surname > $1.surname }
            return
        }
        usersRating = usersRating.sorted { $0.surname < $1.surname }
    }
    
    func makeSortingRating(_ up: Bool) {
        if up {
            usersRating = usersRating.sorted { $0.tokens < $1.tokens }
            return
        }
        usersRating = usersRating.sorted { $0.tokens > $1.tokens }
    }
    
    func makeSortingSpec(_ up: Bool) {
        if up {
            let usersWithSpecialization = usersRating
                .filter { $0.specialization != nil }
                .sorted { $0.specialization! > $1.specialization! }
            let usersWithoutSpecialization = usersRating.filter { $0.specialization == nil }
            usersRating = usersWithSpecialization + usersWithoutSpecialization
            return
        }
        let usersWithSpecialization = usersRating
            .filter { $0.specialization != nil }
            .sorted { $0.specialization! < $1.specialization! }
        let usersWithoutSpecialization = usersRating.filter { $0.specialization == nil }
        usersRating = usersWithSpecialization + usersWithoutSpecialization
    }
    
    func getRating() {
        statsIsLoading = true
        networkManager.requestMoyaData(apis: .getRating)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ getRating successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ getRating]"))
                }
                self.statsIsLoading = false
            } receiveValue: { [unowned self] data in
                do {
                    self.usersRating = try UserRatingModel.decodeFrom(data: data).sorted { $0.tokens > $1.tokens }
//                    debugPrint("OK - \(dataArray)")
                    // po String(decoding: data, as: UTF8.self)
                } catch (let error) {
                    debugPrint(error)
                }
            }
            .store(in: &cancellables)
    }

    
    // MARK: - Other Methods
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
            self?.credentialService.deleteAuthStatus()
            self?.credentialService.deleteAuthToken()
            debugPrint("[AuthStateEnvObject: Token is cleared]")
        }
    }
}

extension AuthStateEnvObject: UIDataUpdatable {
    func updateAllData() {
        //
        Task {
            // Requestor
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
    
    func makeDateFrom(_ dateStr: String) -> Date {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy" // "24-09-2023"
        return inputFormatter.date(from: dateStr) ?? Date()
    }
    
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
    
    private func clearDateLogOut() {
        userDataModel = nil
        userRewardsDataModel = nil
        requestsForMaster = []
        requestsForMasterMonitor = []
        issuesInWork = []
        issuesDone = []
        issuesDeclined = []
        issuesApproved = []
        issuesInProgress = []
        issuesFilteredBoss = []
        logsModel = []
        allStatsFragments = []
        filteredChartFragments = []
        usersRating = []
        notificationCount = 0
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
/*
curl -X 'POST' \
  'https://timofmax1.fvds.ru/create-request' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJUTUstMTAwNSIsImV4cCI6MTcyNzAyOTI2MX0.1E36lx20kFPDRpc0p9hdKSDIHOOsnmzye1fy8XPS56Q' \
  -H 'Content-Type: application/json' \
  -d '{
  "request_type": 3,
  "user_id": 3,
  "area_id": 3,
  "description": "privet boys"
}
'
*/
