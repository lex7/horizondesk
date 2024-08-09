//  Created by Timofey Privalov MobileDesk
//
import Foundation
import SwiftUI
import FirebaseAnalyticsSwift
import FirebaseAnalytics
import UIKit

struct MyAccountScreen: View {
    
    // MARK: - Environment variables
    @EnvironmentObject private var authStateEnvObject: AuthStateEnvObject
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Private State Variables
    @State private var selectedSegment: MyAccountSwitcher = .information
    
    // @State private var workerLoginAccountNumber: String = "TMK-328654"
    // @State private var dateCreated: String =  "2015-04-02"
    
    @State private var alwaysFalse: Bool = false
    @State private var alwaysTrue: Bool = true
    
    @State private var triggerToDisableMfa: Bool = false
    // MARK: - Binding Variables
    @Binding var tabSelection: TabBarItem
    
    // MARK: - Private Constants
    private let generator = UIImpactFeedbackGenerator(style: .light)
    @State private var screenHeight = UIScreen.main.bounds.height
    var body: some View {
        NavigationView {
            VStack {
                // Header
                HStack {
                    topLeftHeader(title: "Мой Профиль")
                    Spacer()
                    topRightHeaderAccount()
                        .onTapGesture {
                            authStateEnvObject.logout {
                                self.generator.impactOccurred()
                                authStateEnvObject.clearToken()
                                if authStateEnvObject.authState == .authorized {
                                    authStateEnvObject.tabBarSelection = .createIssue
                                    authStateEnvObject.authState = .unauthorized
                                }
                            }
                        }
                }
                .offset(y: -5)
                // Segment controller
                HStack {
                    pickerContainer
                        .padding(.horizontal, 12)
                        .background(Color.theme.background)
                }
                // Views inside of switcher
                Group {
                    switch selectedSegment {
                    case .information:
                        ScrollView(showsIndicators: false) {
                            
                            if false {
                                //                            ProgressView()
                                //                                .padding(.top, screenHeight/4)
                            } else {
                                if let userDataModel = authStateEnvObject.userDataModel {
                                    WorkerAccView(
                                                    DeskAccountNumber: Binding(
                                                        get: { userDataModel.username ?? "" },
                                                        set: { authStateEnvObject.userDataModel?.username = $0 }
                                                    ),
                                                    dateCreated: Binding(
                                                        get: { userDataModel.hire_date ?? "" },
                                                        set: { authStateEnvObject.userDataModel?.hire_date = $0 }
                                                    )
                                                )
                                    .padding(.top, 28)
                                    .padding(.bottom, 20)
                                }
                                Divider()
                                Group {
                                    Text("Персональные данные")
                                        .withDefaultTextModifier(font: "NexaBold", size: 15, relativeTextStyle: .subheadline, color: Color.theme.lowContrast)
                                        .padding(.top, 20)
                                    
                                    Group {
                                        if let name = authStateEnvObject.userDataModel?.name,
                                           let middle_name = authStateEnvObject.userDataModel?.middle_name,
                                           let surname = authStateEnvObject.userDataModel?.surname {
                                            titleAndValue(title: "ФИО", value: "\(name) \(middle_name) \(surname)", ifPadding: false)
                                                .padding(.top, 20)
                                        }
                                    }
                                    Group {
                                        if let phone = authStateEnvObject.userDataModel?.phone_number {
                                            titleAndValueMultiLines(title: "Контактный телефон", value: phone)
                                                .padding(.top, 20)
                                        }
                                    }
                                    if let dob = authStateEnvObject.userDataModel?.birth_date {
                                        dateTitleAndValue(title: "Дата Рождения", value: dob, ifPadding: false)
                                            .padding(.top, 20)
                                    }
                                    Group {
                                        if let email = authStateEnvObject.userDataModel?.email {
                                            titleAndValue(title: "Почта", value: email, ifPadding: false)
                                                .padding(.top, 20)
                                        }
                                    }
                                    Group {
                                        if let spec_id = authStateEnvObject.userDataModel?.spec_id {
                                            titleAndValueMultiLines(title: "Специализация", value: RequestTypeEnum(rawValue: spec_id)?.name ?? "")
                                                .padding(.top, 20)
                                        }
                                    }
                                    Group {
                                        if let spec_name = authStateEnvObject.userDataModel?.spec_name {
                                            titleAndValueMultiLines(title: "Должность", value: spec_name)
                                                .padding(.top, 20)
                                                .padding(.bottom, 20)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                Divider()
                                Group {
                                    makeNote(title: "Внимание!", value: NamingDescription.noteChange.txt, lines: 6)
                                        .padding(.top, 20)
                                        .padding(.bottom, 100)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black, .black, .black, .clear]), startPoint: .top, endPoint: .bottom))
                    case .setup:
                        Group {
                            VStack {
                                Group {
                                    
                                    HStack {
                                        Text("Личная статистика")
                                            .withDefaultTextModifier(font: "NexaBold", size: 15, relativeTextStyle: .subheadline, color: Color.theme.lowContrast)
                                        Spacer()
                                    }
                                    .padding(.top, 20)
                                    
                                    Group {
                                        let token = authStateEnvObject.userRewardsDataModel?.tokens ?? 0
                                        titleAndValue(title: "Заработанные токены", value: "\(token)", ifPadding: false)
                                            .padding(.top, 20)
                                    }
                                    Group {
                                        titleAndValueMultiLines(title: "Кол-во заведенных заявок", value: "\(authStateEnvObject.userRewardsDataModel?.num_created ?? 0)")
                                            .padding(.top, 20)
                                    }
                                    Group {
                                        titleAndValueMultiLines(title: "Кол-во исполненных заявок", value: "\(authStateEnvObject.userRewardsDataModel?.num_completed ?? 0)")
                                            .padding(.top, 20)
                                    }
                                    
                                    dateTitleAndValue(title: "Дата последней исполненной заявки", value: "\(authStateEnvObject.userRewardsDataModel?.last_completed ?? "неизвестно")", ifPadding: false)
                                        .padding(.top, 20)
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 28)
            }
            .background(Color.theme.background)
            .navigationBarHidden(true)
        }
    }
}

//#Preview {
//    MyAccountScreen(tabSelection: .constant(.account))
//}

private extension MyAccountScreen {
    
    private func getVoiceOverForSegmentInfo() -> String {
        switch selectedSegment {
        case .information:
            return "My information segment. Segment selected."
        case .setup:
            return "My information segment. Double tap to select segment"
        }
    }
    
    private func getVoiceOverForSegmentSetup() -> String {
        switch selectedSegment {
        case .information:
            return "Setup account segment. Double tap to select segment."
        case .setup:
            return "Setup account segment. Segment selected."
        }
    }
    
    var pickerContainer: some View {
        HStack(alignment: .center, spacing: 4) {
            MyAccountLeftPickerView(sectionSelected: $selectedSegment, label: "Мои Данные")
                .onTapGesture {
                    selectedSegment.toggle()
                    debugPrint(selectedSegment)
                }
                .allowsHitTesting(selectedSegment != .information)
            
            
            MyAccountRightPickerView(sectionSelected: $selectedSegment, label: "Награды")
                .onTapGesture {
                    selectedSegment.toggle()
                    debugPrint(selectedSegment)
                }
                .allowsHitTesting(selectedSegment != .setup)
            
            
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .inset(by: 0.5)
                .stroke(Color.theme.extraLowContrast, lineWidth: 1)
        )
        .background(Color.theme.surface)
        .cornerRadius(28)
    }
}

// - MARK: NavigationView Style
private extension MyAccountScreen {
    func navigationViewSetup() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor.clear
        navBarAppearance.shadowImage = UIImage()
        navBarAppearance.shadowColor = nil
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }
}
