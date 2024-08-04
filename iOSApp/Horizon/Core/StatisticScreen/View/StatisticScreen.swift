//
//  StatisticScreen.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 04.08.2024.
//

import Charts
import SwiftUI

struct StatisticScreen: View {
    
    let data = RealData()
    
    
    var body: some View {
        Chart(RealData.issues, id: \.id) { element in
            SectorMark(
                angle: .value("Sales", element.message),
                innerRadius: .ratio(0.618),
                angularInset: 1.5
            )
        }
    }
}

#Preview {
    StatisticScreen()
}
