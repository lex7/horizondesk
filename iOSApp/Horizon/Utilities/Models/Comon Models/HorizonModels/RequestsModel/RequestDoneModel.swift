//
//  RequestDoneModel.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 09.08.2024.
//

import Foundation

struct RequestDoneModel: Encodable {
    let user_id: Int
    let request_id: Int
}

struct RequesterDeniedModel: Encodable {
    let user_id: Int
    let request_id: Int
    let reason: String
}

struct RequestDeleteModel: Encodable {
    let user_id: Int
    let request_id: Int
}
