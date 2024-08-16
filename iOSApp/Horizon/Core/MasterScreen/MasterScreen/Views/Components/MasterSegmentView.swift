//  Created by Timofey Privalov MobileDesk
import SwiftUI

enum MasterSwitcher: String, CaseIterable, Identifiable  {
    case underMasterApproval = "Master Approval"
    case masterMonitor = "Master Monitor"
    
    mutating func toggle() {
        switch self {
        case .underMasterApproval:
            self = .masterMonitor
        case .masterMonitor:
            self = .underMasterApproval
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
                .foregroundColor(sectionSelected == .underMasterApproval ? Color.theme.selected : Color.theme.mediumContrast)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(sectionSelected == .underMasterApproval ? AnyView(colorScheme == .dark ? Color.gradient.gradientLowDark : Color.gradient.gradientLowLight) : AnyView(Color.theme.surface))
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
                .foregroundColor(sectionSelected == .masterMonitor ? Color.theme.selected : Color.theme.mediumContrast)
        }
        .disabled(sectionSelected == .masterMonitor)
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(sectionSelected == .masterMonitor ? AnyView(colorScheme == .dark ? Color.gradient.gradientLowDark : Color.gradient.gradientLowLight) : AnyView(Color.theme.surface))
        .cornerRadius(24)
    }
}
