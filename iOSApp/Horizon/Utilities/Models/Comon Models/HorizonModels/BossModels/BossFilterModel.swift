//
//  BossModel.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 24.09.2024.
//

import Foundation

struct BossFilterModel: Encodable {
    let from_date: String
    let until_date: String
    let status: String
    let request_type: Int
    let area_id: Int
}
