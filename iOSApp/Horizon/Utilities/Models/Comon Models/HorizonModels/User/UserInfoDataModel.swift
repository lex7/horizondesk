//
//  UserInfoDataModel.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 08.08.2024.
//

import Foundation

struct UserInfoDataModel: Decodable {
    let user_id: Int
    var username: String?
    let surname: String?
    let name: String?
    let middle_name: String?
    var hire_date: String?
    let phone_number: String?
    let birth_date: String?
    let email: String?
    let spec_id: Int
    let spec_name: String?
    let fcm_token: [String?]
    let role_id: Int
    let shift_id: Int?
}

extension UserInfoDataModel {
    init(data: Data) throws {
        let decoder = JSONDecoder()
        self = try decoder.decode(UserInfoDataModel.self, from: data)
    }
}
