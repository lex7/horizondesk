//
//  AllStatsModel.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 24.09.2024.
//

import Foundation

struct FragmentModel: Decodable, Hashable {
    let date: String
    let events: Int
}

extension FragmentModel {
    static func decodeFrom(data: Data) throws -> [FragmentModel] {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode([FragmentModel].self, from: data)
        } catch {
            throw error 
        }
    }
}


