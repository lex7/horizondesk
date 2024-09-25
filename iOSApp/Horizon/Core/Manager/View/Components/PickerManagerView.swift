//
//  PickerManagerView.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 25.09.2024.
//

import SwiftUI

enum ManagerSwitcher: CaseIterable, Identifiable  {
    case allStats
    case filteredStats
    
    mutating func toggle() {
        switch self {
        case .allStats:
            self = .filteredStats
        case .filteredStats:
            self = .allStats
        }
    }
    var id: Self { self }
}

struct ManagerLeftSegmentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var sectionSelected: ManagerSwitcher
    var label: String
    
    init(sectionSelected: Binding<ManagerSwitcher>, label: String) {
        self._sectionSelected = sectionSelected
        self.label = label
    }

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(label)
                .font(
                    Font.custom("NexaBold", size: 13)
                        .weight(.bold)
                )
                .multilineTextAlignment(.trailing)
                .foregroundColor(sectionSelected == .allStats ? Color.theme.selected : Color.theme.mediumContrast)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(sectionSelected == .allStats ? AnyView(colorScheme == .dark ? Color.gradient.gradientLowDark : Color.gradient.gradientLowLight) : AnyView(Color.theme.surface))
        .cornerRadius(24)
    }
}

struct ManagerRightSegmentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var sectionSelected: ManagerSwitcher
    var label: String
    
    init(sectionSelected: Binding<ManagerSwitcher>, label: String) {
        self._sectionSelected = sectionSelected
        self.label = label
    }

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(label)
                .font(
                    Font.custom("NexaBold", size: 13)
                        .weight(.bold)
                )
                .multilineTextAlignment(.trailing)
                .foregroundColor(sectionSelected == .filteredStats ? Color.theme.selected : Color.theme.mediumContrast)
        }
        .disabled(sectionSelected == .filteredStats)
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(sectionSelected == .filteredStats ? AnyView(colorScheme == .dark ? Color.gradient.gradientLowDark : Color.gradient.gradientLowLight) : AnyView(Color.theme.surface))
        .cornerRadius(24)
    }
}
