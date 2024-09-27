//
//  PieChartView.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 27.09.2024.
//

import SwiftUI
import Charts
import Foundation

struct TypeSpecPieChart: View {
    let data: [(name: String, count: Int)]
    let topSpec: (name: String, count: Int)
    var generator: UIImpactFeedbackGenerator
    let cumulativeSalesRangesForStyles: [(name: String, range: Range<Double>)]
    var totalAmount: Int
    @State var selectedSales: Double? = nil
    
    
    init(data: [(name: String, count: Int)], topSpec: (name: String, count: Int), totalAmount: Int, generator: UIImpactFeedbackGenerator) {
        self.data = data
        self.topSpec = topSpec
        var cumulative = 0.0
        self.cumulativeSalesRangesForStyles = data.map {
            let newCumulative = cumulative + Double($0.count)
            let result = (name: $0.name, range: cumulative ..< newCumulative)
            cumulative = newCumulative
            return result
        }
        self.totalAmount = totalAmount
        self.generator = generator
    }
    
    var selectedStyle: (name: String, count: Int)? {
        if let selectedSales,
           let selectedIndex = cumulativeSalesRangesForStyles
            .firstIndex(where: { $0.range.contains(selectedSales) }) {
            return data[selectedIndex]
        }
        
        return nil
    }

    var body: some View {
        Chart(data, id: \.name) { element in
            SectorMark(
                angle: .value("Кол-во", element.count),
                innerRadius: .ratio(0.618),
                angularInset: 1.5
            )
            .cornerRadius(5.0)
            .foregroundStyle(by: .value("тип", element.name))
            .opacity(element.name == (selectedStyle?.name ?? topSpec.name) ? 1 : 0.35)
            
        }
        .chartLegend(alignment: .center, spacing: 18)
        .chartAngleSelection(value: $selectedSales)
        .scaledToFit()
        .chartGesture { chart in
            SpatialTapGesture()
                .onEnded { event in
                    let angle = chart.angle(at: event.location)
                    chart.selectAngleValue(at: angle)
                    generator.impactOccurred()
                }
        }
        .chartBackground { chartProxy in
            GeometryReader { geometry in
                let frame = geometry[chartProxy.plotFrame!]
                VStack {
                    Group {
                        if let partAmount = selectedStyle?.count {
                            Text("Доля: \(partAmount*100/totalAmount)%")
                                .withDefaultTextModifier(font: "NexaRegular", size: 15,
                                                         relativeTextStyle: .callout, color: .secondary)
                        } else {
                            Text("Доля: \(topSpec.count*100/totalAmount)%")
                                .withDefaultTextModifier(font: "NexaRegular", size: 15,
                                                         relativeTextStyle: .callout, color: .secondary)
                        }
                    }
                    .padding(.bottom, 3)
                    Text(selectedStyle?.name ?? topSpec.name)
                        .withDefaultTextModifier(font: "NexaBold", size: 18,
                                                 relativeTextStyle: .headline, color: Color.theme.primary)
                    Text("кол-во: " + (selectedStyle?.count.formatted() ?? topSpec.count.formatted()))
                        .withDefaultTextModifier(font: "NexaRegular", size: 15,
                                                 relativeTextStyle: .callout, color: .secondary)
                        .padding(.top, 3)
                }
                .position(x: frame.midX, y: frame.midY)
            }
        }
    }
    
    private func calculate() {
        
    }
}
