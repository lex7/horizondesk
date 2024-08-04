//
//  RawDataStats.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 04.08.2024.
//

import Foundation

// в каком формате даты:

//struct RealData {
//    
//    static let issueCreatedDate = generateRandomDate(daysBack: 365) // Random date within the past year
//    static let issueDeadlineDate = generateRandomDate(daysBack: 30) // Random date within the past month
//    static let  createdDateString = formatDate(issueCreatedDate)
//    static let deadlineDateString = formatDate(issueDeadlineDate)
//
//    static let issues: [IssueModel] = [.init(id: UUID().uuidString,
//                                             subject: (SpecializationIssue.allCases.randomElement() ?? .safety).name,
//                                             message: "Check Region \(Int.random(in: Range(1...10)))",
//                                             region: "Участок \(Int.random(in: Range(1...4)))",
//                                             status: (IssueStatus.allCases.randomElement() ?? .new).descriptionIssuer,
//                                             created: createdDateString,
//                                             deadline: deadlineDateString,
//                                             completed: createdDateString,
//                                             addedJustification: ""),
//                                       .init(id: UUID().uuidString,
//                                             subject: (SpecializationIssue.allCases.randomElement() ?? .safety).name,
//                                             message: "Check Region \(Int.random(in: Range(1...10)))",
//                                             region: "Участок \(Int.random(in: Range(1...4)))",
//                                             status: (IssueStatus.allCases.randomElement() ?? .new).descriptionIssuer,
//                                             created: createdDateString,
//                                             deadline: deadlineDateString,
//                                             completed: createdDateString,
//                                             addedJustification: ""),
//                                       .init(id: UUID().uuidString,
//                                             subject: (SpecializationIssue.allCases.randomElement() ?? .safety).name,
//                                             message: "Check Region \(Int.random(in: Range(1...10)))",
//                                             region: "Участок \(Int.random(in: Range(1...4)))",
//                                             status: (IssueStatus.allCases.randomElement() ?? .new).descriptionIssuer,
//                                             created: createdDateString,
//                                             deadline: deadlineDateString,
//                                             completed: createdDateString,
//                                             addedJustification: ""),
//                                       .init(id: UUID().uuidString,
//                                             subject: (SpecializationIssue.allCases.randomElement() ?? .safety).name,
//                                             message: "Подметите в столовой",
//                                             region: "Участок \(Int.random(in: Range(1...4)))",
//                                             status: (IssueStatus.allCases.randomElement() ?? .new).descriptionIssuer,
//                                             created: createdDateString,
//                                             deadline: deadlineDateString,
//                                             completed: createdDateString,
//                                             addedJustification: ""),
//                                       .init(id: UUID().uuidString,
//                                             subject: (SpecializationIssue.allCases.randomElement() ?? .safety).name,
//                                             message: "Check Region \(Int.random(in: Range(1...10)))",
//                                             region: "Участок \(Int.random(in: Range(1...4)))",
//                                             status: (IssueStatus.allCases.randomElement() ?? .new).descriptionIssuer,
//                                             created: createdDateString,
//                                             deadline: deadlineDateString,
//                                             completed: createdDateString,
//                                             addedJustification: ""),
//                                       .init(id: UUID().uuidString,
//                                             subject: (SpecializationIssue.allCases.randomElement() ?? .safety).name,
//                                             message: "Check Region \(Int.random(in: Range(1...10)))",
//                                             region: "Участок \(Int.random(in: Range(1...4)))",
//                                             status: (IssueStatus.allCases.randomElement() ?? .new).descriptionIssuer,
//                                             created: createdDateString,
//                                             deadline: deadlineDateString,
//                                             completed: createdDateString,
//                                             addedJustification: ""),
//                                       .init(id: UUID().uuidString,
//                                             subject: (SpecializationIssue.allCases.randomElement() ?? .safety).name,
//                                             message: "Check Region \(Int.random(in: Range(1...10)))",
//                                             region: "Участок \(Int.random(in: Range(1...4)))",
//                                             status: (IssueStatus.allCases.randomElement() ?? .new).descriptionIssuer,
//                                             created: createdDateString,
//                                             deadline: deadlineDateString,
//                                             completed: createdDateString,
//                                             addedJustification: ""),
//                                ]
////    let FabricData: FabricModel = FabricModel(fabricName: .Ekb, issues: issues)
//}
//
//extension RealData {
//    static private func generateRandomDate(daysBack: Int) -> Date {
//        let day = arc4random_uniform(UInt32(daysBack)) + 1 // Random day up to 'daysBack'
//        let hour = arc4random_uniform(24) // Random hour
//        let minute = arc4random_uniform(60) // Random minute
//
//        let today = Date()
//        let gregorian = Calendar(identifier: .gregorian)
//        var offsetComponents = DateComponents()
//        offsetComponents.day = -Int(day)
//        offsetComponents.hour = -Int(hour)
//        offsetComponents.minute = -Int(minute)
//
//        return gregorian.date(byAdding: offsetComponents, to: today)!
//    }
//    
//    static private func formatDate(_ date: Date) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd-MMM-yyyy'T'HH:mm'Z'"
//        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
//        return dateFormatter.string(from: date)
//    }
//}
