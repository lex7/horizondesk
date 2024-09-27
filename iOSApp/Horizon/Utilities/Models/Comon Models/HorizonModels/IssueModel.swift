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
    let reason: String?
    
    var createdAtString: String {
        guard let created = created_at else { return "N/A" }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: created)
    }
    
    /// For ChartPie
    var specializationName: String {
        RequestTypeEnum(rawValue: request_type)?.shortName ?? ""
    }
    
    /// For ChartPie
    var chartStatusName: String {
        IssueStatus(rawValue: request_type)?.descriptionShort ?? ""
    }
    
    var updatedAtString: String {
        guard let created = updated_at else { return "N/A" }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: created)
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
