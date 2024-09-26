//  Created by Timofey Privalov on 31.01.2024.
import SwiftUI

struct CustomTabBarView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var authStateEnvObject: AuthStateEnvObject
    
    let tabs: [TabBarItem]
    @Binding var selection: TabBarItem
    @Namespace private var namespace
    @State var localSelection: TabBarItem
    
    var body: some View {
        tabBarVersion2
            .onChange(of: selection, perform: { value in
                withAnimation(.easeInOut) {
                    localSelection = value
                }
            })
    }
}

struct CustomTabBarView_Previews: PreviewProvider {
    
    static let tabs: [TabBarItem] = [
        .createIssue,
        .monitorIssue,
        .executeIssue,
        .masterReviewIssue,
        .account
    ]
    
    static var previews: some View {
        VStack {
            Spacer()
            CustomTabBarView(tabs: tabs, selection: .constant(tabs[0]), localSelection: tabs[2])
        }
    }
}

extension CustomTabBarView {
    private func switchToTab(tab: TabBarItem) {
        selection = tab
    }
}

extension CustomTabBarView {
    private func tabView2(tab: TabBarItem) -> some View {
            VStack {
                Image(systemName: tab.iconName)
                    .withDefaultTextModifier(font: "NexaRegular", size: 18, relativeTextStyle: .subheadline, color: Color.theme.lowContrast)
                    .contentShape(Circle())
            }
            .foregroundColor(localSelection == tab ? tab.color : Color.gray)
            .padding(12)
            .frame(maxWidth: .infinity)
            .overlay(
                Group {
                    ZStack {
                        if localSelection == tab {
                            Group {
                                Circle()
                                    .fill(colorScheme == .dark ? Color.gradient.gradientLowDark : Color.gradient.gradientLowLight)
                                    .matchedGeometryEffect(id: "back_rectangle", in: namespace)
                                    .overlay {
                                        Image(systemName: tab.iconName)
                                            .font(.system(size: 18, weight: .regular))
                                            .foregroundColor(.clear)
                                            .background(
                                                Color.gradient.gradientHigh
                                                    .mask(
                                                        Image(systemName: tab.iconName)
                                                            .font(.system(size: 18, weight: .regular))
                                                    )
                                            )
                                    }
                            }
                            .contentShape(Circle())
                        }
                    }
                }
            )
    }
    
    private var tabBarVersion2: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                tabView2(tab: tab)
                    .contentShape(Circle())
                    .onTapGesture {
                        switchToTab(tab: tab)
                        switch tab {
                        case .executeIssue:
                            authStateEnvObject.executorUnassignRequest()
                            authStateEnvObject.executorMyTasksRequest()
                        case .account:
                            authStateEnvObject.getUserInfoData()
                            authStateEnvObject.getUserRewardsData()
                        default:
                            debugPrint()
                        }
                    }
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 40))
        .padding(12)
        .background(Color.theme.tabBarBG.opacity(0.44).ignoresSafeArea(edges: .bottom))
        .cornerRadius(40)
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 39)
    }
}
