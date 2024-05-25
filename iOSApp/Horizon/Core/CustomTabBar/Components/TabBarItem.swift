//  Created by Timofey Privalov on 31.01.2024.
import Foundation
import SwiftUI

enum TabBarItem: Hashable {
    case createIssue, monitorIssue, reviewIssue, executeIssue, account
    var iconName: String {
        if #available(iOS 16, *) {
            switch self {
            case .createIssue: return "paperplane.circle"
            case .monitorIssue: return "folder.circle"
            case .executeIssue: return "doc.text"
            case .reviewIssue: return "arrow.up.arrow.down"
            case .account: return "person.text.rectangle"
            }
        } else {
            switch self {
            case .createIssue: return "chart.pie"
            case .monitorIssue: return "dollarsign.circle"
            case .reviewIssue: return "arrow.up.arrow.down"
            case .executeIssue: return "doc.text"
            case .account: return "person.text.rectangle"
            }
        }
    }
    
    var color: Color {
        switch self {
        case .createIssue: return Color.green
        case .monitorIssue: return Color.red
        case .reviewIssue: return Color.blue
        case .executeIssue: return Color.positivePrimary
        case .account: return Color.orange
        }
    }
}
