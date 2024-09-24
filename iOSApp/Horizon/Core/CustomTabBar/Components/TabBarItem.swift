//  Created by Timofey Privalov on 31.01.2024.
import Foundation
import SwiftUI

enum TabBarItem: Hashable, Equatable {
    case createIssue, monitorIssue, executeIssue, masterReviewIssue, account, manager
    var iconName: String {
        switch self {
        case .createIssue: return "paperplane.circle"
        case .monitorIssue: return "folder.circle"
        case .executeIssue: return "arrow.up.arrow.down"
        case .masterReviewIssue: return "doc.text"
        case .account: return "person.text.rectangle"
        case .manager: return "square.3.layers.3d.down.left"
        }
    }
    
    var color: Color {
        switch self {
        case .createIssue: return Color.green
        case .monitorIssue: return Color.red
        case .executeIssue: return Color.blue
        case .masterReviewIssue: return Color.positivePrimary
        case .account: return Color.orange
        case .manager: return Color.orange
        }
    }
}
