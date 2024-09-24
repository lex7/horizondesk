//
//  RegionIssue.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 04.08.2024.
//

import Foundation

enum RegionIssue: Int {
    case areaOne = 1
    case areaTwo = 2
    case areaThree = 3
    case areaFour = 4
    case empty = 5
    
    var name: String {
        switch self {
        case .areaOne:
            return "Участок #1"
        case .areaTwo:
            return "Участок #2"
        case .areaThree:
            return "Участок #3"
        case .areaFour:
            return "Участок #4"
        case .empty:
            return ""
        }
    }
}


enum StatusIssue: String {
    case done = "done"
    case inProgress = "in-progress"
    case denied = "denied"
    
    var name: String {
        switch self {
        case .done:
            return "Выполнены"
        case .inProgress:
            return "В Работе"
        case .denied:
            return "Отклонены"
        }
    }
}
