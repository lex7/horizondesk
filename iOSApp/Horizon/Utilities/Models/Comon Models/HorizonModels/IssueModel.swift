//
// MobileDesk
//  DeskHorizon
//
//  Created by Timofey Privalov MobileDesk
import Foundation
import SwiftUI

struct IssueModel: Hashable, Codable {
    let id: String
    let subject: String
    let message: String
    let region: String
    let status: String
    let created: String
    let deadline: String
    let completed: String
    
    var readableStatus: String {
        return IssueStatus(rawValue: status)?.descriptionIssuer ?? "unknown"
    }
    
    var progressIssuerColor: Color {
        return IssueStatus(rawValue: status)?.colorIssuer ?? .highContrast
    }
    
    var progressSolverColor: Color {
        return IssueStatus(rawValue: status)?.colorSolver ?? .highContrast
    }
    
    var statusOfElement: IssueStatus? {
        return IssueStatus(rawValue: status)
    }
}

extension IssueModel {
    init(data: Data) throws {
        let decoder = JSONDecoder()
        self = try decoder.decode(IssueModel.self, from: data)
    }
}
