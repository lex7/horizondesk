//  Created by Timofey Privalov MobileDesk
//
import SwiftUI

enum IssuesMontitorSwitcher: String, CaseIterable, Identifiable, Equatable  {
    case masterReview = "MonitorPickerView"
    case done = "MonitorDonePickerView"
    case declined = "MonitorRejectedPickerView"
    var id: Self { self }
}


struct MonitorPickerView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var sectionSelected: IssuesMontitorSwitcher
    var label: String
    
    init(sectionSelected: Binding<IssuesMontitorSwitcher>, label: String) {
        self._sectionSelected = sectionSelected
        self.label = label
    }

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(label)
                .withMultiTextModifier(font: "NexaBold", size: 13, relativeTextStyle: .footnote, color: sectionSelected == .masterReview ? Color.theme.selected : Color.theme.mediumContrast)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(sectionSelected == .masterReview ? AnyView(colorScheme == .dark ? Color.gradient.gradientLowDark : Color.gradient.gradientLowLight) : AnyView(Color.theme.surface))
        .cornerRadius(24)
    }
}

struct MonitorDonePickerView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var sectionSelected: IssuesMontitorSwitcher
    var label: String
    
    init(sectionSelected: Binding<IssuesMontitorSwitcher>, label: String) {
        self._sectionSelected = sectionSelected
        self.label = label
    }

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(label)
                .withMultiTextModifier(font: "NexaBold", size: 13, relativeTextStyle: .footnote, color: sectionSelected == .done ? Color.theme.selected : Color.theme.mediumContrast)
                .multilineTextAlignment(.trailing)
        }
        .disabled(sectionSelected == .done)
        .padding(.horizontal, 4)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(sectionSelected == .done ? AnyView(colorScheme == .dark ? Color.gradient.gradientLowDark : Color.gradient.gradientLowLight) : AnyView(Color.theme.surface))
        .cornerRadius(24)
    }
}

struct MonitorRejectedPickerView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var sectionSelected: IssuesMontitorSwitcher
    var label: String
    
    init(sectionSelected: Binding<IssuesMontitorSwitcher>, label: String) {
        self._sectionSelected = sectionSelected
        self.label = label
    }

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(label)
                .withMultiTextModifier(font: "NexaBold", size: 13, relativeTextStyle: .footnote, color: sectionSelected == .declined ? Color.theme.selected : Color.theme.mediumContrast)
                .multilineTextAlignment(.trailing)
        }
        .disabled(sectionSelected == .declined)
        .padding(.horizontal, 4)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(sectionSelected == .declined ? AnyView(colorScheme == .dark ? Color.gradient.gradientLowDark : Color.gradient.gradientLowLight) : AnyView(Color.theme.surface))
        .cornerRadius(24)
    }
}
