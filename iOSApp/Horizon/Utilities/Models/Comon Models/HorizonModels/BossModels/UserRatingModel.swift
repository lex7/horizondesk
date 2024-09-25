//
//  UserRatingModel.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 25.09.2024.
//

import Foundation

struct UserRatingModel: Decodable, Hashable {
    let user_id: Int
    let surname: String
    let name: String
    let middle_name: String
    let tokens: Int
    let num_created: Int
    let specialization: String?
    let num_completed: Int
}

extension UserRatingModel {
    static func decodeFrom(data: Data) throws -> [UserRatingModel] {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode([UserRatingModel].self, from: data)
        } catch {
            throw error
        }
    }
}
