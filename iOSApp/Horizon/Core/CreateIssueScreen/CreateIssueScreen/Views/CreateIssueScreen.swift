//  Created by Timofey Privalov MobileDesk
import SwiftUI

struct CreateIssueScreen: View {
    
    // MARK: - Environment variables
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var authStateEnvObject: AuthStateEnvObject
    
    // MARK: - Binding Variables
    @Binding var tabSelection: TabBarItem

    // MARK: - Private Constants
    private let generator = UIImpactFeedbackGenerator(style: .light)
    @State private var screenHeight = UIScreen.main.bounds.height
    @State private var screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack {
            //Background Layer
            Color.theme.background
                .ignoresSafeArea()
            VStack {
                HStack {
                    topLeftHeader(title: "Заявить")
                        .layoutPriority(1)
                    Spacer()
                    makeAdditionalHeader()
                        .layoutPriority(1)
                        .padding(.trailing, 28)
                } // End HStack - Logo
                .offset(y: -5)
                ScrollView(showsIndicators: false) {
                    SendMessageView()
                }
            } // End of VStack
            .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black, .black, .black, .clear]), startPoint: .top, endPoint: .bottom).ignoresSafeArea(edges: .top))
            .background(Color.theme.background.ignoresSafeArea(edges: .bottom))
            .onChange(of: tabSelection) {
                if tabSelection == .createIssue {
                    authStateEnvObject.getInProgressIssue()
                }
            }
        }
    }
}

#Preview {
    CreateIssueScreen(tabSelection: .constant(.createIssue))
}

private extension CreateIssueScreen {
    @ViewBuilder
    func makeAdditionalHeader() -> some View {
        HStack(spacing: 10) {
            Group {
                if authStateEnvObject.notificationCount != 0 {
                    Group {
                        makeMediumContrastView(text: "", image: "bell", color: .selected, size: 18, txtStyle: .headline)
                        labelWithColoredPadding(txt: "\(authStateEnvObject.notificationCount)", size: 11, relativeTextStyle: .caption2, color: Color.theme.extraLowContrast, bkColor: .selected)
                            .offset(y: -2)
                    }
                    .onTapGesture {
                        Task {
                            authStateEnvObject.notificationCount = 0
                            generator.prepare()
                            try await Task.sleep(nanoseconds: 50_000_000)
                            generator.impactOccurred()
                            authStateEnvObject.tabBarSelection = .monitorIssue
                        }
                        
                    }
                }
            }
            .contentShape(Rectangle())
        }
    }
}
