//
//  RequestTypeEnum.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 04.08.2024.
//

import Foundation

enum RequestTypeEnum: Int, CaseIterable {
    case electricity = 1
    case tools = 2
    case sanpin = 3
    case safety = 4
    case docs = 5
    case empty = 6
    
    var name: String {
        switch self {
        case .electricity:
            return "Электрика"
        case .tools:
            return "Инструменты"
        case .sanpin:
            return "Санитарно-Бытовые условия"
        case .safety:
            return "Безопасность Труда"
        case .docs:
            return "Документооборот"
        case .empty:
            return ""
        }
    }
    
    var requestType: Int {
        switch self {
        case .electricity: return 1
        case .tools: return 2
        case .sanpin: return 3
        case .safety: return 4
        case .docs: return 5
        case .empty: return 777
        }
    }
}
