//
//  ChartAllTime.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 24.09.2024.
//

import SwiftUI
import Foundation
import Charts
import GameplayKit


private let gaussianRandoms = GKGaussianDistribution(lowestValue: 0, highestValue: 20)
func date(year: Int, month: Int, day: Int = 1) -> Date {
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
}


struct DailySalesChart: View {
    @Binding var scrollPosition: Date
    @Binding var dataForChart:: [(day: Date, events: Int)]
    
    var body: some View {
        Chart {
            ForEach(dataForChart, id: \.day) {
                BarMark(
                    x: .value("День", $0.day, unit: .day),
                    y: .value("Кол-во", $0.events)
                )
                .foregroundStyle(.primaryFire)
            }
            .foregroundStyle(.blue)
        }
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: 3600 * 24 * 30)
        .chartScrollTargetBehavior(
            .valueAligned(
                matching: .init(hour: 0),
                majorAlignment: .matching(.init(day: 1))))
        .chartScrollPosition(x: $scrollPosition)
        
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 7)) {
                AxisTick()
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
    }
}


struct EventsMockData {
    /// Sales by day for the last 30 days.
    static let last365Days: [(day: Date, events: Int)] = stride(from: 0, to: 200, by: 1).compactMap {
        let startDay: Date = date(year: 2022, month: 11, day: 17)
        let day: Date = Calendar.current.date(byAdding: .day, value: $0, to: startDay)!
        let dayNumber = Double($0)
        
        var events = randomEventAmountForDay(dayNumber)
        let dayOfWeek = Calendar.current.component(.weekday, from: day)
        if dayOfWeek == 6 {
            events += gaussianRandoms.nextInt() * 3
        } else if dayOfWeek == 7 {
            events += gaussianRandoms.nextInt()
        } else {
            events = Int(Double(events) * Double.random(in: 4...5) / Double.random(in: 5...6))
        }
        return (
            day: day,
            events: events
        )
    }
    
    private static func randomEventAmountForDay(_ dayNumber: Double) -> Int {
        // Add noise to the generated data.
        let yearlySeasonality = 100.0 * (0.5 - 0.5 * cos(2.0 * .pi * (dayNumber / 364.0)))
        let monthlySeasonality = 10.0 * (0.5 - 0.5 * cos(2.0 * .pi * (dayNumber / 30.0)))
        let weeklySeasonality = 30.0 * (1 - cos(2.0 * .pi * ((dayNumber + 2.0) / 7.0)))
        return Int(yearlySeasonality + monthlySeasonality + weeklySeasonality + Double(gaussianRandoms.nextInt()))
    }
}



