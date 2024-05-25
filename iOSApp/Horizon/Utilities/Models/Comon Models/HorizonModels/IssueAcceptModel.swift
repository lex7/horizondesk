//
// MobileDesk
//  DeskHorizon
//
//  Created by Timofey Privalov MobileDesk
import Foundation

struct IssueAcceptModel: Encodable {
    let id: String
    let deadline: String
}

struct IssueDeclineModel: Encodable {
    let id: String
    let completed: String
}

struct IssueDoneModel: Encodable {
    let id: String
    let completed: String
}

struct IssueIdModel: Encodable {
    let id: String
}
