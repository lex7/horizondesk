//  Created by Timofey Privalov on 31.01.2024.
import SwiftUI

struct CustomTabBarContainer<Content: View>: View {
    
    @Binding var selection: TabBarItem
    let content: Content
    @State private var tabs: [TabBarItem] = []
    
    init(selection: Binding<TabBarItem>, @ViewBuilder content: () -> Content) {
        self._selection = selection
        self.content = content()
    }
var body: some View {
        ZStack(alignment: .bottom) {
            content
//                .ignoresSafeArea()
            CustomTabBarView(tabs: tabs, selection: $selection, localSelection: selection)
        }
        .onPreferenceChange(TabBarItemsPreferenceKey.self, perform: { value in
            self.tabs = value
        })
    }
}

struct CustomTabBarContainerContainer_Previews: PreviewProvider {
    static let tabs: [TabBarItem] = [
        .createIssue,
        .monitorIssue,
        .executeIssue,
        .masterReviewIssue,
        .account
    ]
    
    static var previews: some View { CustomTabBarContainer(selection: .constant(tabs.first!)) {
        Color.red
        }
    }
}
