//
//  MasterDesiction.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 06.08.2024.
//

import Foundation

struct MasterApproveModel: Encodable {
    let user_id: Int
    let request_id: Int
    let deadline: String
}
