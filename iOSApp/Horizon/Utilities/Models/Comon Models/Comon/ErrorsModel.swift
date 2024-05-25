//  Created by Timofey Privalov MobileDesk
import Foundation

struct SimpleError: LocalizedError {
    private var message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    var errorDescription: String? {
        return message
    }
}
