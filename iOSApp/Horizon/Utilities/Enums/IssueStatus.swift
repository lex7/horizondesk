//
// MobileDesk
//  DeskHorizon
//
//  Created by Timofey Privalov MobileDesk
import Foundation
import SwiftUI

enum IssueStatus: Int, CaseIterable {
    case new = 1
    case approved = 2
    case declined = 3
    case inprogress = 4
    case review = 5
    case done = 6
    
    var descriptionIssuer: String {
        switch self {
        case .new:
            return "на рассмотрении"
        case .approved:
            return "утверждено"
        case .declined:
            return "отклонено"
        case .inprogress:
            return "в работе"
        case .review:
            return "требует подтверждения"
        case .done:
            return "выполнено"
        }
    }
    
    /// For ChartPie
    var descriptionShort: String {
        switch self {
        case .new, .approved, .inprogress, .review:
            return "в работе"
        case .done:
            return "выполнено"
        case .declined:
            return "отклонено"
        }
    }

    var colorIssuer: Color {
        switch self {
        case .new:
            return .theme.vibrant
        case .approved:
            return .theme.primary
        case .declined:
            return .theme.negativePrimary
        case .inprogress:
            return .theme.primary
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
        case .declined:
            return .theme.negativePrimary
        case .inprogress:
            return .theme.primaryFire
        case .review:
            return .theme.positiveSecondary
        case .done:
            return .theme.positivePrimary
        }
    }
    
    var colorLogs: Color {
        switch self {
        case .new:
            return .theme.primary
        case .approved:
            return .theme.primaryAmber
        case .declined:
            return .theme.negativePrimary
        case .inprogress:
            return .theme.primaryFire
        case .review:
            return .theme.positiveSecondary
        case .done:
            return .theme.positivePrimary
        }
    }
}
