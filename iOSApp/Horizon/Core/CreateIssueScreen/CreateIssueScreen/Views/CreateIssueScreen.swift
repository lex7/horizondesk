//  Created by Timofey Privalov MobileDesk
import SwiftUI

struct CreateIssueScreen: View {
    
    // MARK: - Environment variables
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var authStateEnvObject: AuthStateEnvObject
    
    // MARK: - Binding Variables
    @Binding var tabSelection: TabBarItem

    // MARK: - Private Constants
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
            .onAppear {
                authStateEnvObject.assignFcmHorizon()
            }
            .onChange(of: tabSelection) { value in
                if tabSelection == .createIssue {
                    authStateEnvObject.getIssues()
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
                Group {
                    makeMediumContrastView(text: "", image: "bell", color: .selected, size: 18, txtStyle: .headline)
                    labelWithColoredPadding(txt: "2", size: 11, relativeTextStyle: .caption2, color: Color.theme.extraLowContrast, bkColor: .selected)
                        .offset(y: -2)
                }
            }
            .contentShape(Rectangle())
        }
    }
}
