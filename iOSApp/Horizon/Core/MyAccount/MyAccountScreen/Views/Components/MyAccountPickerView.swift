//  Created by Timofey Privalov MobileDesk
import SwiftUI

enum MyAccountSwitcher: String, CaseIterable, Identifiable  {
    case information = "My Information"
    case setup = "Rewards"
    
    mutating func toggle() {
        switch self {
        case .information:
            self = .setup
        case .setup:
            self = .information
        }
    }
    var id: Self { self }
}


struct MyAccountLeftPickerView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var sectionSelected: MyAccountSwitcher
    var label: String
    
    init(sectionSelected: Binding<MyAccountSwitcher>, label: String) {
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
                .foregroundColor(sectionSelected == .information ? Color.theme.selected : Color.theme.mediumContrast)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(sectionSelected == .information ? AnyView(colorScheme == .dark ? Color.gradient.gradientLowDark : Color.gradient.gradientLowLight) : AnyView(Color.theme.surface))
        .cornerRadius(24)
    }
}

struct MyAccountRightPickerView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var sectionSelected: MyAccountSwitcher
    var label: String
    
    init(sectionSelected: Binding<MyAccountSwitcher>, label: String) {
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
                .foregroundColor(sectionSelected == .setup ? Color.theme.selected : Color.theme.mediumContrast)
        }
        .disabled(sectionSelected == .setup)
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(sectionSelected == .setup ? AnyView(colorScheme == .dark ? Color.gradient.gradientLowDark : Color.gradient.gradientLowLight) : AnyView(Color.theme.surface))
        .cornerRadius(24)
    }
}
