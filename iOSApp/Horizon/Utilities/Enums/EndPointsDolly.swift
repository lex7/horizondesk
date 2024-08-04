//  Created by Timofey Privalov MobileDesk
import Foundation
import CombineMoya
import Combine
import Moya

enum EndPointsDolly {
    //case assignFcmToken(model: HorizonFcmModel)
    case login(model: LoginModel)
    case requests
    case createRequest(message: RequestModelIssue)
    case acceptIssue(issue: IssueAcceptModel)
    case declineIssue(issue: IssueDeclineModel)
    case inprogress(model: UserIdModel)
    case review(model: IssueIdModel)
    case done(model: IssueDoneModel)
    
    var baseStrUrl: String {
        switch self {
        default:
            return "http://34.141.180.59:443/"
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
        case .login, .createRequest, .acceptIssue, .declineIssue, .review, .done:
            return .post
        case .requests, .inprogress:
            return .get
        }
    }
    
    var task: Moya.Task {
        // FIXME: - IN future refactoring add replace parameters with appropriate model, ex.: case - updateSetting
        switch self {
        case .login(let model):
            return .requestJSONEncodable(model)
        case .createRequest(let message):
            return .requestJSONEncodable(message)
        case .acceptIssue(let message):
            return .requestJSONEncodable(message)
        case .declineIssue(let message):
            return .requestJSONEncodable(message)
        case .requests:
            return .requestPlain
        case .inprogress(let model):
            return .requestParameters(parameters: ["user_id": model.user_id], encoding: URLEncoding.queryString)
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
        case .login:
            return "login"
        case .requests:
            return "requests"
        case .createRequest:
            return "create-request"
        case .acceptIssue:
            return "approve-issue"
        case .declineIssue:
            return "decline-issue"
        case .inprogress:
            return "in-progress"
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

