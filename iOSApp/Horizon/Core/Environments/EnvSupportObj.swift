//  Created by Timofey Privalov MobileDesk
//
import Foundation
import Combine

final class EnvSupportObj: ObservableObject {
    
    @Published var issueTheme: String = ""
    @Published var issueMessage: String = ""
    @Published var areaOfIssueNumber: String = ""
    // MARK: - Published properties
    @Published var isIssueCreated: Bool = false
    @Published var isErrorOccured: Bool = false
    
    // MARK: - Private constants
    private let networkManager = NetworkManager.standard
    
    // MARK: - Private variables
    private var cancellables: Set<AnyCancellable> = []
    
    private func makeDateStamp() -> String {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd-MMM-yyyy'T'HH:mm'Z'"
        let timeCreate = outputFormatter.string(from: Date())
        return timeCreate
    }
    
    func sendIssues(action: @escaping () -> ()) {
        action()
        isIssueCreated = false
        let model = IssueModel(id: "", subject: issueTheme, message: issueMessage, region: areaOfIssueNumber, status: "", created: makeDateStamp(), deadline: "", completed: "")
        networkManager.requestMoyaData(apis: .sendIssue(message: model))
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
                self?.isIssueCreated = true
                
            }
            .store(in: &cancellables)
    }
}

enum SpecializationIssue {
    case tools
    case docs
    case sanpin
    case safety
    case empty
    
    var name: String {
        switch self {
        case .tools:
            return "Инструменты"
        case .docs:
            return "Документооборот"
        case .sanpin:
            return "Санитарно-Бытовые условия"
        case .safety:
            return "Безопасность Труда"
        case .empty:
            return ""
        }
    }
}

enum RegionIssue {
    case areaOne
    case areaTwo
    case areaThree
    case areaFour
    case empty
    
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
