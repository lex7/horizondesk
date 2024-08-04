//
//  RoleEnum.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 04.08.2024.
//

import Foundation

enum RoleEnum: Int {
    case worker = 1
    case master = 2
    case statistic = 3
    
    var name: String {
        switch self {
        case .worker:
            return "рабочий"
        case .master:
            return "мастер"
        case .statistic:
            return "босс статистика"
        }
    }
}


/*
user_id - add to other requests
position_id:
1 - рабочий
2 - мастер
4 - босс
*/
