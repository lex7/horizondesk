//
//  ManagerViewModel.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 23.09.2024.
//

import Foundation


final class ManagerViewModel: ObservableObject {
    
    func date(year: Int, month: Int, day: Int = 1) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
    }
    
}
