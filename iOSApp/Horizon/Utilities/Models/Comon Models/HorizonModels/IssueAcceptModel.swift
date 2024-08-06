//
// MobileDesk
//  DeskHorizon
//
//  Created by Timofey Privalov MobileDesk
import Foundation

struct IssueDoneModel: Encodable {
    let id: String
    let completed: String
}

struct UserIdModel: Encodable {
    let user_id: Int
}
