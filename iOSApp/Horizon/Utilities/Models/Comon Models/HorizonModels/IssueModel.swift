//
// MobileDesk
//  DeskHorizon
//
//  Created by Timofey Privalov MobileDesk
import Foundation
import SwiftUI

struct RequestModelIssue: Codable, Hashable {
    let request_type: Int
    let user_id: Int
    let area_id: Int
    let description: String
}

struct IssueModel: Hashable, Codable {
    let id: String
    let subject: String
    let message: String
    let region: String
    let status: String
    let created: String
    let deadline: String
    let completed: String
    // New
    let addedJustification: String?
    
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
