//  Created by Timofey Privalov MobileDesk
import Foundation
import CombineMoya
import Combine
import Moya

enum EndPointsDolly {
    case assignFcmToken(model: HorizonFcmModel)
    case getIssues
    case sendIssue(message: IssueModel)
    case acceptIssue(issue: IssueAcceptModel)
    case declineIssue(issue: IssueDeclineModel)
    case inprogress(model: IssueIdModel)
    case review(model: IssueIdModel)
    case done(model: IssueDoneModel)
    
    var baseStrUrl: String {
        switch self {
        default:
            return "http://158.160.66.207:8000/"
        }
    }
    
    var baseHeaders: [String: String]? {
        switch self {
        default:
            return ["*/*": "Accept", "application/json": "Content-Type"]
        }
    }
}



extension EndPointsDolly: Moya.TargetType {
    
    private static let lock = NSLock()
    
    var baseURL: URL {
        guard let url = URL(string: self.baseStrUrl) else { fatalError() }
        return url
    }
    
    var method: Moya.Method {
        switch self {
        case .assignFcmToken, .sendIssue, .acceptIssue, .declineIssue, .inprogress, .review, .done:
            return .post
        case .getIssues:
            return .get
        }
    }
    
    var task: Moya.Task {
        // FIXME: - IN future refactoring add replace parameters with appropriate model, ex.: case - updateSetting
        switch self {
        case .assignFcmToken(let model):
            return .requestJSONEncodable(model)
        case .sendIssue(let message):
            return .requestJSONEncodable(message)
        case .acceptIssue(let message):
            return .requestJSONEncodable(message)
        case .declineIssue(let message):
            return .requestJSONEncodable(message)
        case .getIssues:
            return .requestPlain
        case .inprogress(let model):
            return .requestJSONEncodable(model)
        case .review(let model):
            return .requestJSONEncodable(model)
        case .done(let model):
            return .requestJSONEncodable(model)
        }
    }

    
    var headers: [String: String]? {
        return [
            "accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
    
    var path: String {
        switch self {
        case .assignFcmToken:
            return "assign-fcm"
        case .getIssues:
            return "get-issues"
        case .sendIssue:
            return "send-issue"
        case .acceptIssue:
            return "approve-issue"
        case .declineIssue:
            return "decline-issue"
        case .inprogress:
            return "inprogress"
        case .review:
            return "send-review"
        case .done:
            return "done"
        }
    }
    
    var appropriateDecoder: JSONDecoder {
        switch self {
        default:
            let decoder = JSONDecoder()
            return decoder
        }
    }
    
    var errorDecoder: JSONDecoder {
        switch self {
        default:
            return JSONDecoder()
        }
    }
}

