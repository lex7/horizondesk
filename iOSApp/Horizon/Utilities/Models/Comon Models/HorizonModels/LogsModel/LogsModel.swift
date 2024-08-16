//
//  LogsModel.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 09.08.2024.
//

import Foundation

struct LogsModel: Decodable, Hashable {
    let log_id: Int
    let request_id: Int
    let old_status_id: Int?
    let new_status_id: Int
    let changed_at: Date
    let changed_by: Int
    let reason: String?
    let changer_name: String
    let action_name: String
    
    var сhangedAtString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: changed_at)
    }
}

extension LogsModel {
    static func decode(from data: Data) throws -> [LogsModel] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return try decoder.decode([LogsModel].self, from: data)
    }
}
