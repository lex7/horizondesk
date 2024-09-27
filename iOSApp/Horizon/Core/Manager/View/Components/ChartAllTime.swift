//
//  ChartAllTime.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 24.09.2024.
//

import SwiftUI
import Foundation
import Charts

struct DailySalesChart: View {
    // MARK: - Private properties
    private let generator = UIImpactFeedbackGenerator(style: .light)
    
    // MARK: - Binding
    @Binding var scrollPosition: Date
    @Binding var dataForChart: [(day: Date, events: Int)]
    @Binding var visibleDomain: Int
    
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
        .chartXVisibleDomain(length: 3600 * 24 * visibleDomain)
        .chartScrollTargetBehavior(
            .valueAligned(
                matching: .init(hour: 0),
                majorAlignment: .matching(.init(day: 1))))
        .chartScrollPosition(x: $scrollPosition)
        .onChange(of: scrollPosition) { _ in
            generator.prepare()
            generator.impactOccurred()
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 7)) {
                AxisTick()
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
    }
}


