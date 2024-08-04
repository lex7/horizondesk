//
// MobileDesk
//  DeskHorizon
//
//  Created by Timofey Privalov MobileDesk
import Foundation
import SwiftUI



enum IssueStatus: String, CaseIterable {
    case new
    case approved
    case declined
    case inprogress
    case review
    case done
    
    var descriptionIssuer: String {
        switch self {
        case .new:
            return "на рассмотрении"
        case .approved:
            return "утверждено"
        case .inprogress:
            return "в работе"
        case .declined:
            return "отклонено"
        case .review:
            return "требует подтверждения"
        case .done:
            return "выполнено"
        }
    }

    var colorIssuer: Color {
        switch self {
        case .new:
            return .theme.primary
        case .approved:
            return .theme.primary
        case .inprogress:
            return .theme.primary
        case .declined:
            return .theme.negativePrimary
        case .review:
            return .theme.primaryFire
        case .done:
            return .theme.positivePrimary
        }
    }
    
    var colorSolver: Color {
        switch self {
        case .new:
            return .theme.primary
        case .approved:
            return .theme.primaryAmber
        case .inprogress:
            return .theme.primaryFire
        case .declined:
            return .theme.negativePrimary
        case .review:
            return .theme.positiveSecondary
        case .done:
            return .theme.positivePrimary
        }
    }
}
