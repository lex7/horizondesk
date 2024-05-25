//  Created by Timofey Privalov MobileDesk
import Foundation


enum APIError: Error, LocalizedError {
    case unknown, apiError(reason: String)
    case parserError(reason: String)
    case networkError(from: URLError)
    case apiResponseCode(code: Int)
    case urlError
    case refreshError(message: String)
    case simpleError(message: String)
        
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case .apiError(let reason), .parserError(let reason):
            return reason
        case .networkError(let from):
            return from.localizedDescription
        case .urlError:
            return "error url"
        case .simpleError(let message):
            return message
        case .refreshError(let message):
            return message
        case .apiResponseCode(let code):
            return "\(code)"
        }
    }
}
