//
// MobileDesk
//  DeskHorizon
//
//  Created by Timofey Privalov MobileDesk
import Foundation

struct RequestDoneModel: Encodable {
    let user_id: Int
    let request_id: Int
}

struct RequesterDeniedModel: Encodable {
    let user_id: Int
    let request_id: Int
    let reason: String
}

struct RequestDeleteModel: Encodable {
    let user_id: Int
    let request_id: Int
}

struct UserIdModel: Encodable {
    let user_id: Int
}
