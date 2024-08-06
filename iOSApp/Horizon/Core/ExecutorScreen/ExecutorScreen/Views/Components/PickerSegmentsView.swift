//  Created by Timofey Privalov MobileDesk
import SwiftUI

enum TransactionSwitcher: String, CaseIterable, Identifiable  {
    case unassignedTask = "unassigned"
    case myTasks = "my tasks"
    
    mutating func toggle() {
        switch self {
        case .unassignedTask:
            self = .myTasks
        case .myTasks:
            self = .unassignedTask
        }
    }
    var id: Self { self }
}

struct ExecutorLeftSegmentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var sectionSelected: TransactionSwitcher
    var label: String
    
    init(sectionSelected: Binding<TransactionSwitcher>, label: String) {
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
                .foregroundColor(sectionSelected == .unassignedTask ? Color.theme.selected : Color.theme.mediumContrast)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(sectionSelected == .unassignedTask ? AnyView(colorScheme == .dark ? Color.gradient.gradientLowDark : Color.gradient.gradientLowLight) : AnyView(Color.theme.surface))
        .cornerRadius(24)
    }
}

struct ExecutorRightSegmentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var sectionSelected: TransactionSwitcher
    var label: String
    
    init(sectionSelected: Binding<TransactionSwitcher>, label: String) {
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
                .foregroundColor(sectionSelected == .myTasks ? Color.theme.selected : Color.theme.mediumContrast)
        }
        .disabled(sectionSelected == .myTasks)
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(sectionSelected == .myTasks ? AnyView(colorScheme == .dark ? Color.gradient.gradientLowDark : Color.gradient.gradientLowLight) : AnyView(Color.theme.surface))
        .cornerRadius(24)
    }
}
