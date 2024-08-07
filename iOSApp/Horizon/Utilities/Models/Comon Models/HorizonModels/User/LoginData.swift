//
//  LoginData.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 08.08.2024.
//

import Foundation

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
