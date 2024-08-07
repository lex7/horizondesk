//
// MobileDesk
//  DeskHorizon
//
//  Created by Timofey Privalov MobileDesk
import Foundation

struct LoginModel: Encodable {
    let username: String
    let password: String
    let fcm_token: String
}

