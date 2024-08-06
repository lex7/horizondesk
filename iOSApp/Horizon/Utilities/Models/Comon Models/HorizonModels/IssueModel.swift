//
// MobileDesk
//  DeskHorizon
//
//  Created by Timofey Privalov MobileDesk
import Foundation
import SwiftUI

struct CreateRequestModelIssue: Codable, Hashable {
    let request_type: Int
    let user_id: Int
    let area_id: Int
    let description: String
}

/*
 {
   "request_id": 8,
   "request_type": 2,
   "created_by": 11,
   "assigned_to": null,
   "area_id": 2,
   "description": "Hello World",
   "status_id": 1,
   "created_at": "2024-08-04T10:33:56.388073",
   "updated_at": null,
   "deadline": null,
   "rejection_reason": null
 }
 */

struct RequestIssueModel: Hashable, Codable {
    let request_id: Int
    let request_type: Int
    let created_by: Int
    let assigned_to: Int?
    let area_id: Int
    let description: String?
    let status_id: Int
    let created_at: Date?
    let updated_at: Date?
    let deadline: Date?
    let rejection_reason: String?
    
    var createdAtString: String {
        guard let created = created_at else { return "N/A" }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: created)
    }
    
    var updatedAtString: String {
        guard let updated = updated_at else { return "N/A" }
        return DateFormatter.localizedString(from: updated, dateStyle: .medium, timeStyle: .medium)
    }
    
    var deadlineAtString: String {
        guard let deadline = deadline else { return "N/A" }
        return DateFormatter.localizedString(from: deadline, dateStyle: .medium, timeStyle: .medium)
    }
    
    var readableStatus: String {
        return IssueStatus(rawValue: status_id)?.descriptionIssuer ?? "unknown"
    }
    
    var progressIssuerColor: Color {
        return IssueStatus(rawValue: status_id)?.colorIssuer ?? .highContrast
    }
    
    var progressSolverColor: Color {
        return IssueStatus(rawValue: status_id)?.colorSolver ?? .highContrast
    }
    
    var statusOfElement: IssueStatus? {
        return IssueStatus(rawValue: status_id)
    }
}

extension RequestIssueModel {
    static func decode(from data: Data) throws -> [RequestIssueModel] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return try decoder.decode([RequestIssueModel].self, from: data)
    }
}
