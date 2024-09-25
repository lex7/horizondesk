//  Created by Timofey Privalov MobileDesk
import Foundation
import Combine
import CombineMoya
import Alamofire
import Moya

final class NetworkManager {
    static let shared = NetworkManager()
    static var cancelable = Set<AnyCancellable>()
    var provider: MoyaProvider<EndPointsDolly>
    
    static let standard = NetworkManager()
    
    private init() {
        // 1. Set up the configuration and evaluator directly here.
        let configuration = URLSessionConfiguration.af.default
        let manager = ServerTrustManager(evaluators: ["corp3.cybertrain4security.ru": DisabledEvaluator(),
                                                      "timofmax1.fvds.ru": DisabledEvaluator()])
        let session = Session(configuration: configuration, serverTrustManager: manager)

        // 2. Initialize the `provider` property with the session.
        provider = MoyaProvider<EndPointsDolly>(session: session)
    }

    func requestMoyaData(apis: EndPointsDolly) -> AnyPublisher<Data, APIError> {
        Future<Data, APIError> { promise in
            self.provider.requestPublisher(apis)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(.apiError(reason: error.localizedDescription)))
                    }
                }, receiveValue: { response in
                    switch response.statusCode {
                    case 200...299:
                        promise(.success(response.data))
                        response.data
                    default:
                        promise(.failure(.apiResponseCode(code: response.statusCode)))
                        // po String(decoding: response.data, as: UTF8.self)
                    }
                })
                .store(in: &NetworkManager.cancelable)
        }
        .eraseToAnyPublisher()
    }
}

struct DisabledEvaluator: ServerTrustEvaluating {
    func evaluate(_ trust: SecTrust, forHost host: String) throws {
    }
}
