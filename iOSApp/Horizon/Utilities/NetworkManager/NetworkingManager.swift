//  Created by Timofey Privalov MobileDesk
import Foundation
import Combine
import CombineMoya
import Moya

final class NetworkManager {
    
    static let standard = NetworkManager()
    static var cancelable = Set<AnyCancellable>()
    private init() {}
    
    private let headers = [
        "Content-Type": "application/json",
        "Accept": "application/json"
    ]

    func requestMoyaData(apis: EndPointsDolly) -> AnyPublisher<Data, APIError> {
        Future<Data, APIError> { promise in
            let provider = MoyaProvider<EndPointsDolly>()
            debugPrint("[🌏 request: \(apis.path)]")
            provider.requestPublisher(apis)
                .sink(receiveCompletion: { completion in
                    switch completion{
                    case .finished:
                        debugPrint("🌏 RECEIVE VALUE COMPLETED: ✅\(apis.path)")
                    case .failure:
                        promise(.failure(.apiError(reason: "Response takes too much time")))
                    }
                }, receiveValue: { response in
                    switch response.statusCode {
                    case 200...299:
                        promise(.success(response.data))
                    default:
                        promise(.failure(.apiResponseCode(code: response.statusCode)))
                    }
                    // po String(decoding: response.data, as: UTF8.self)
                    // po String(decoding: response.request!.httpBody!, as: UTF8.self)
                })
                .store(in: &NetworkManager.cancelable)
        }.eraseToAnyPublisher()
    }
}
