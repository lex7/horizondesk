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


struct FcmRefreshModel: Encodable {
    let user_id: Int
    let fcm_token: String
}

struct FcmOldModel: Encodable {
    let user_id: Int
    let fcm_token: String
}




