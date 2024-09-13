//  Created by Timofey Privalov MobileDesk
import Foundation
import Combine
import CombineMoya
import Moya

final class NetworkManager {
    
    private static let lock = NSLock()
    
    static let standard = NetworkManager()
    static var cancelable = Set<AnyCancellable>()
    private init() {}
    
    func requestMoyaData(apis: EndPointsDolly) -> AnyPublisher<Data, APIError> {
        Future<Data, APIError> { promise in
            let provider = MoyaProvider<EndPointsDolly>()
            debugPrint("[🌏 request: \(apis.path)]")
            provider.requestPublisher(apis)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        debugPrint("🌏 RECEIVE VALUE COMPLETED: ✅\(apis.path)")
                    case .failure(let error):
                        error.response
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
                    // po String(decoding: data, as: UTF8.self)
                    // po String(decoding: response.request!.httpBody!, as: UTF8.self)
                })
                .store(in: &NetworkManager.cancelable)
        }.eraseToAnyPublisher()
    }
}
