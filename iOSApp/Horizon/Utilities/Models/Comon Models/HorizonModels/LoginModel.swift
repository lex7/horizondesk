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

struct LoginData: Decodable {
    let user_id: Int
    let role_id: Int
}

extension LoginData {
    init(data: Data) throws {
        let decoder = JSONDecoder()
        self = try decoder.decode(LoginData.self, from: data)
    }
}
