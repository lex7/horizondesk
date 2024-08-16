//
//  TakeIntoWorkModek.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 06.08.2024.
//

import Foundation

struct ExecutorActionModel: Encodable {
    let user_id: Int
    let request_id: Int
    let reason: String?
}

struct ExecutorCancelModel: Encodable {
    let user_id: Int
    let request_id: Int
    let reason: String
}
