//  Created by Timofey Privalov MobileDesk
import SwiftUI

enum MasterSwitcher: String, CaseIterable, Identifiable  {
    case reviewTab = "reviewTab"
    case notInUseTab = "notInUseTab"
    
    mutating func toggle() {
        switch self {
        case .reviewTab:
            self = .notInUseTab
        case .notInUseTab:
            self = .reviewTab
        }
    }
    var id: Self { self }
}


struct MasterLeftSegmentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var sectionSelected: MasterSwitcher
    var label: String
    
    init(sectionSelected: Binding<MasterSwitcher>, label: String) {
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
                .foregroundColor(sectionSelected == .reviewTab ? Color.theme.selected : Color.theme.mediumContrast)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(sectionSelected == .reviewTab ? AnyView(colorScheme == .dark ? Color.gradient.gradientLowDark : Color.gradient.gradientLowLight) : AnyView(Color.theme.surface))
        .cornerRadius(24)
    }
}

struct MasterRightSegmentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var sectionSelected: MasterSwitcher
    var label: String
    
    init(sectionSelected: Binding<MasterSwitcher>, label: String) {
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
                .foregroundColor(sectionSelected == .notInUseTab ? Color.theme.selected : Color.theme.mediumContrast)
        }
        .disabled(sectionSelected == .notInUseTab)
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(sectionSelected == .notInUseTab ? AnyView(colorScheme == .dark ? Color.gradient.gradientLowDark : Color.gradient.gradientLowLight) : AnyView(Color.theme.surface))
        .cornerRadius(24)
    }
}

