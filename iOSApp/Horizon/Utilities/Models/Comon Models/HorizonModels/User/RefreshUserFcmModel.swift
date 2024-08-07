//
//  RefreshUserModel.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 08.08.2024.
//

import Foundation


struct RefreshUserFcmModel: Encodable {
    let user_id: Int
    let new_fcm: String
}
