//  Created by Timofey Privalov MobileDesk
//
import Foundation
import Combine

final class EnvSupportObj: ObservableObject {
    @Published var requestType: Int = 0
    @Published var issueMessage: String = ""
    @Published var areaOfIssueNumber: Int = 999
    // MARK: - Published properties
    @Published var isIssueCreated: Bool = false
    @Published var isErrorOccured: Bool = false
    
    // MARK: - Private constants
    private let networkManager = NetworkManager.standard
    private var credentialService = CredentialService.standard
    
    // MARK: - Private variables
    private var cancellables: Set<AnyCancellable> = []
    
    private func makeDateStamp() -> String {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd-MMM-yyyy'T'HH:mm'Z'"
        let timeCreate = outputFormatter.string(from: Date())
        return timeCreate
    }
    
    func createRequestIssue() {
        isIssueCreated = false
        let model = RequestModelIssue(request_type: requestType,
                                      user_id: credentialService.getUserId() ?? 777,
                                      area_id: areaOfIssueNumber,
                                      description: issueMessage)
        networkManager.requestMoyaData(apis: .createRequest(message: model))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    debugPrint(String(describing: "[vm: ✅ sendIssues successfully]"))
                    break
                case .failure(let error):
                    debugPrint(String(describing: "[vm: \(error) - ❌ sendIssues]"))
                }
            } receiveValue: { [weak self] _ in
                debugPrint(model)
                self?.isIssueCreated = true
            }
            .store(in: &cancellables)
    }
}


enum RegionIssue: Int {
    case areaOne = 1
    case areaTwo = 2
    case areaThree = 3
    case areaFour = 4
    case empty = 5
    
    var name: String {
        switch self {
        case .areaOne:
            return "Участок #1"
        case .areaTwo:
            return "Участок #2"
        case .areaThree:
            return "Участок #3"
        case .areaFour:
            return "Участок #4"
        case .empty:
            return ""
        }
    }
}
