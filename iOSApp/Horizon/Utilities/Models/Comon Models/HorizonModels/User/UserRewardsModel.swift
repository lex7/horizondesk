//
//  UserRewardsModel.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 08.08.2024.
//

import Foundation

struct UserRewardsModel: Decodable {
    let tokens: Int
    let num_created: Int
    let num_completed: Int
    let last_completed: String?
}

extension UserRewardsModel {
    init(data: Data) throws {
        let decoder = JSONDecoder()
        self = try decoder.decode(UserRewardsModel.self, from: data)
    }
}
