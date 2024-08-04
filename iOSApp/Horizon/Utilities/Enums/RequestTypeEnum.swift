//
//  RequestTypeEnum.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 04.08.2024.
//

import Foundation

enum SpecializationIssue: String, CaseIterable {
    case electricity
    case tools
    case sanpin
    case safety
    case docs
    case empty
    
    var name: String {
        switch self {
        case .electricity:
            return "Электричество"
        case .tools:
            return "Инструменты"
        case .docs:
            return "Документооборот"
        case .sanpin:
            return "Санитарно-Бытовые условия"
        case .safety:
            return "Безопасность Труда"
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
