//
//  FabricModel.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 04.08.2024.
//

import Foundation

struct FabricModel {
    var fabricName: FabricCity
    var issues: [IssueModel]
}

enum IssueType: CaseIterable {
    case electric
    case tool
    case documentation
    case environment
    case qos
    case hr
    
    var name: String {
        switch self {
        case .electric:
            return "электрика"
        case .tool:
            return "инструмент"
        case .documentation:
            return "документация"
        case .environment:
            return "окружающая среда"
        case .qos:
            return "качество производства"
        case .hr:
            return "кадры"
        }
    }
}

enum FabricCity {
    case Moscow
    case Ekb
    
    var name: String {
        switch self {
        case .Ekb:
            return "Екатеринбург"
        case .Moscow:
            return "Москва"
        }
    }
}
