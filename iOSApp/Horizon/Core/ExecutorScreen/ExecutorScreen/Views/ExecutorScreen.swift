//  Created by Timofey Privalov MobileDesk
//
import Foundation
import UIKit
import SwiftUI

struct ExecutorScreen: View {
    
    // MARK: - Environment variables
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var authStateEnvObject: AuthStateEnvObject
    
    // MARK: - View Model
    
    // MARK: - Private Constants
    private let generator = UIImpactFeedbackGenerator(style: .light)
    @State private var screenHeight = UIScreen.main.bounds.height
    
    init() {
        navigationViewSetup()
    }
    
    // MARK: - Body View
    var body: some View {
        VStack {
            HStack {
                topLeftHeader(title: "Задания")
                Spacer()
            }
            
            HStack {
                pickerContainer
                    .padding(.horizontal, 12)
                    .background(Color.theme.background)
            }
            .frame(maxWidth: .infinity)
            switch authStateEnvObject.executorSegment {
            case .unassignedTask:
                Group {
                    switch authStateEnvObject.issuesApproved.isEmpty {
                    case true:
                        VStack {
                            messageForEmptyList
                                .padding(.top, screenHeight/4)
                            Spacer()
                        }
                    case false:
                        newIssues
                        .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black, .black, .black, .clear]), startPoint: .top, endPoint: .bottom))
                    }
                } // History Tab
                .background(Color.theme.background)
            case .myTasks:
                Group {
                    switch authStateEnvObject.issuesInProgress.isEmpty {
                    case true:
                        VStack {
                            messageForEmptyList
                                .padding(.top, screenHeight/4)
                            Spacer()
                        }
                    case false:
                        inProgressIssues
                        .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black, .black, .black, .clear]), startPoint: .top, endPoint: .bottom))
                    }
                }
            } 
        } /// End of Vstack
        .onAppear {
            authStateEnvObject.executorUnassignRequest()
            authStateEnvObject.executorMyTasksRequest()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .background(Color.theme.background)
    } 
}

#Preview {
    ExecutorScreen()
}


private extension ExecutorScreen {
    var newIssues: some View {
        ScrollView {
            ForEach(authStateEnvObject.issuesApproved, id: \.self) { issue in
                Menu {
                    Button("Взять в работу") {
                        generator.impactOccurred()
                        authStateEnvObject.executerTakeOnWork(issue.request_id) {
                            authStateEnvObject.executorUnassignRequest()
                        }
                    }
                    Button("Отмена") {
                        generator.impactOccurred()
                        authStateEnvObject.executorUnassignRequest()
                    }
                } label: {
                    issueCellFor(issue)
                }
            }
        }
        .padding(.bottom, screenHeight/11)
    }
    
    var inProgressIssues: some View {
        ScrollView {
            ForEach(authStateEnvObject.issuesInProgress, id: \.self) { issue in
                Menu {
                    Button("Отправить на проверку.") {
                        generator.impactOccurred()
                        authStateEnvObject.executerCompleteSendReview(issue.request_id) {
                             authStateEnvObject.executorMyTasksRequest()
                        }
                    }
                    Button("Отмена") {
                        generator.impactOccurred()
                        authStateEnvObject.executorMyTasksRequest()
                    }
                } label: {
                    issueCellFor(issue)
                }
            }
        }
        .padding(.bottom, screenHeight/11)
    }
}

private extension ExecutorScreen {
    
    func titleHeader(
        _ title: String,
        lines: Int = 2,
        color: Color = Color.theme.highContrast,
        size: CGFloat = 17,
        relativeTextStyle: Font.TextStyle = .headline,
        uppercase: Bool = true,
        font: String = "NexaRegular") -> some View {
        Group {
            if uppercase {
                Text(title)
                    .textCase(.uppercase)
                    .withMultiTextModifier(
                        font: font,
                        size: size,
                        relativeTextStyle: relativeTextStyle,
                        color: color,
                        lines: lines
                    )
            } else {
                Text(title)
                    .withMultiTextModifier(
                        font: font,
                        size: size,
                        relativeTextStyle: relativeTextStyle,
                        color: color,
                        lines: lines
                    )
            }
        }
    }
    
    @ViewBuilder
    func issueCellFor(_ issue: RequestIssueModel) -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                titleHeader(RequestTypeEnum(rawValue: issue.request_type)?.name ?? "", lines: 3)
                Spacer()
                descriptionOfField(RegionIssue(rawValue: issue.area_id)?.name ?? "", color: Color.theme.secondary)
            }
            HStack(spacing: 0) {
                GeometryReader { geometry in
                    HStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 2)
                            .frame(height: 8)
                            .foregroundStyle(issue.progressSolverColor)
                            .frame(width: (geometry.size.width))
                    }
                }
            }
            HStack {
                switch authStateEnvObject.executorSegment {
                case .unassignedTask:
                    titleHeader(RequestTypeEnum(rawValue: issue.request_type)?.name ?? "", color: .highContrast, uppercase: false)
                case .myTasks:
                    titleHeader(RequestTypeEnum(rawValue: issue.request_type)?.name ?? "", color: .theme.negativePrimary, uppercase: false)
                }
            }
            .padding(.top, 10)
            switch authStateEnvObject.issueDebtSegment {
            case .inProgress:
                HStack {
                    descriptionOfField(issue.readableStatus, color: Color.theme.secondary)
                    Spacer()
                    // new, approved, declined, inprogress, review, done
                    createDateString(issue)
                        .padding(.top, screenHeight/120)
                }
            case .done:
                HStack {
                    descriptionOfField(issue.readableStatus, color: Color.theme.secondary)
                    Spacer()
                    // new, approved, declined, inprogress, review, done
                    createDateString(issue)
                        .padding(.top, screenHeight/120)
                }
            case .declined:
                HStack {
                    descriptionOfField(issue.readableStatus, color: Color.theme.secondary)
                    Spacer()
                    // new, approved, declined, inprogress, review, done
                    createDateString(issue)
                        .padding(.top, screenHeight/120)
                }
            }
        }
        .onChange(of: authStateEnvObject.executorSegment) { value in
            authStateEnvObject.executorUnassignRequest()
            authStateEnvObject.executorMyTasksRequest()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.theme.surface) // Fills the background with yellow color.
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.theme.extraLowContrast, lineWidth: 1) // Adds a red stroke with a line width of 2.
        )
    }
    
    @ViewBuilder
    private func createDateString(_ issue: RequestIssueModel) -> some View {
        if let status = issue.statusOfElement {
            switch status {
            case .new:
                HStack(spacing: 3) {
                    descriptionOfField("создано:", color: Color.theme.lowContrast)
                    descriptionOfField(issue.createdAtString, color: Color.theme.lowContrast)
                }
            case .approved:
                HStack(spacing: 3) {
                    descriptionOfField("до:", color: Color.theme.lowContrast)
                    descriptionOfField(issue.deadlineAtString, color: Color.theme.lowContrast)
                }
            case .declined:
                HStack(spacing: 3) { // completed ??
                    descriptionOfField(issue.deadlineAtString, color: Color.theme.lowContrast)
                }
            case .inprogress:
                HStack(spacing: 3) {
                    descriptionOfField("до:", color: Color.theme.lowContrast)
                    descriptionOfField(issue.deadlineAtString, color: Color.theme.lowContrast)
                }
            case .review:
                HStack {
                    descriptionOfField(issue.deadlineAtString, color: Color.theme.lowContrast)
                }
            case .done:
                HStack {
                    descriptionOfField(issue.deadlineAtString, color: Color.theme.lowContrast)
                }
            }
        } else {
            EmptyView()
        }
    }
}


// - MARK: View Components
private extension ExecutorScreen {
    var pickerContainer: some View {
        HStack(alignment: .center, spacing: 4) {
            ExecutorLeftSegmentView(sectionSelected: $authStateEnvObject.executorSegment, label: "Не назначенные")
                .onTapGesture {
                    authStateEnvObject.executorSegment.toggle()
                    generator.prepare()
                    generator.impactOccurred()
                    
                }
                .allowsHitTesting(authStateEnvObject.executorSegment != .unassignedTask)
            ExecutorRightSegmentView(sectionSelected: $authStateEnvObject.executorSegment, label: "Мои Задания")
                .onTapGesture {
                    authStateEnvObject.executorSegment.toggle()
                    generator.prepare()
                    generator.impactOccurred()
                }
                .allowsHitTesting(authStateEnvObject.executorSegment != .myTasks)
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
    
    @ViewBuilder
    private var messageForEmptyList: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(NamingEnum.noTasks.name)
                .withDefaultTextModifier(font: "NexaRegular", size: 16, relativeTextStyle: .callout, color: Color.theme.lowContrast)
            Text(NamingTextEnum.emptyScreenTransaction.name)
                .lineLimit(8)
                .lineSpacing(5)
                .multilineTextAlignment(.leading)
                .withDefaultTextModifier(font: "NexaRegular", size: 13, relativeTextStyle: .footnote, color: Color.theme.lowContrast)
        }
        .padding(.horizontal, 24)
    }
}

// - MARK: NavigationView Style
private extension ExecutorScreen {
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
