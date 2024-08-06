//  Created by Timofey Privalov MobileDesk
import Foundation
import CombineMoya
import Combine
import Moya

enum EndPointsDolly {
    //case assignFcmToken(model: HorizonFcmModel)
    case login(model: LoginModel)
    case requests
    case createRequest(message: CreateRequestModelIssue)
    /// Creator
    case inprogress(model: UserIdModel)
    case denied(model: UserIdModel)
    /// Master
    case underMasterApproval(model: UserIdModel)
    case masterApprove(model: MasterApproveModel)
    case masterDeny(model: MasterDenyModel)
    /// Executor
    case unassigned(model: UserIdModel)
    case myTasks(model: UserIdModel)
    case takeOnWork(model: ExecutorActionModel)
    case executerCancel(model: ExecutorActionModel)
    case executorComplete(model: ExecutorActionModel)
    
    case completed(model: UserIdModel)
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
        case .login, .createRequest, .done, .masterDeny,
                .masterApprove, .takeOnWork, .executerCancel, .executorComplete:
            return .post
        case .requests, .inprogress, .completed, .denied, .underMasterApproval, .unassigned, .myTasks:
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
        case .requests:
            return .requestPlain
        case .inprogress(let model), .denied(let model), .completed(let model),
                .underMasterApproval(let model), .unassigned(let model), .myTasks(let model):
            return .requestParameters(parameters: ["user_id": model.user_id], encoding: URLEncoding.queryString)
        case .masterApprove(let model):
            return .requestJSONEncodable(model)
        case .masterDeny(let model):
            return .requestJSONEncodable(model)
        case .takeOnWork(let model):
            return .requestJSONEncodable(model)
        case .executorComplete(let model):
            return .requestJSONEncodable(model)
        case .executerCancel(let model):
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
        case .inprogress:
            return "in-progress"
        case .completed:
            return "completed"
        case .denied:
            return "denied"
        case .underMasterApproval:
            return "under-master-approval"
        case .masterDeny:
            return "master-deny"
        case .masterApprove:
            return "master-approve"
        case .unassigned:
            return "unassigned"
        case .myTasks:
            return "my-tasks"
        case .takeOnWork:
            return "take-on-work"
        case .executerCancel:
            return "executor-cancel"
        case .executorComplete:
            return "executor-complete"
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

