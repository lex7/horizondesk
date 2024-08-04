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
            switch authStateEnvObject.transactionSegment {
            case .history:
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
            case .upcoming:
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
//                        authStateEnvObject.inProgressIssue(id: issue.id) {
//                            authStateEnvObject.getIssues()
//                        }
                    }
                    Button("Отмена") {
                        generator.impactOccurred()
                        authStateEnvObject.getIssues()
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
                        authStateEnvObject.toReviewIssue(id: issue.id) {
                            authStateEnvObject.getIssues()
                        }
                    }
                    Button("Отмена") {
                        generator.impactOccurred()
                        authStateEnvObject.getIssues()
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
    func issueCellFor(_ issue: IssueModel) -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                titleHeader(issue.subject, lines: 3)
                Spacer()
                descriptionOfField(issue.region, color: Color.theme.secondary)
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
                switch authStateEnvObject.transactionSegment {
                case .history:
                    titleHeader(issue.message, color: .highContrast, uppercase: false)
                case .upcoming:
                    titleHeader(issue.message, color: .theme.negativePrimary, uppercase: false)
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
        .onChange(of: authStateEnvObject.transactionSegment) { value in
            authStateEnvObject.getIssues()
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
    private func createDateString(_ issue: IssueModel) -> some View {
        if let status = issue.statusOfElement {
            switch status {
            case .new:
                HStack(spacing: 3) {
                    descriptionOfField("создано:", color: Color.theme.lowContrast)
                    descriptionOfField(issue.created.getTimeHorizon(), color: Color.theme.lowContrast)
                }
            case .approved:
                HStack(spacing: 3) {
                    descriptionOfField("до:", color: Color.theme.lowContrast)
                    descriptionOfField(issue.deadline.getDateHorizon(), color: Color.theme.lowContrast)
                }
            case .declined:
                HStack(spacing: 3) {
                    descriptionOfField(issue.completed.getTimeHorizon(), color: Color.theme.lowContrast)
                }
            case .inprogress:
                HStack(spacing: 3) {
                    descriptionOfField("до:", color: Color.theme.lowContrast)
                    descriptionOfField(issue.deadline.getDateHorizon(), color: Color.theme.lowContrast)
                }
            case .review:
                HStack {
                    descriptionOfField(issue.deadline.getDateHorizon(), color: Color.theme.lowContrast)
                }
            case .done:
                HStack {
                    descriptionOfField(issue.completed.getDateHorizon(), color: Color.theme.lowContrast)
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
            ExecutorLeftSegmentView(sectionSelected: $authStateEnvObject.transactionSegment, label: "Не назначенные")
                .onTapGesture {
                    authStateEnvObject.transactionSegment.toggle()
                    generator.prepare()
                    generator.impactOccurred()
                    
                }
                .allowsHitTesting(authStateEnvObject.transactionSegment != .history)
            ExecutorRightSegmentView(sectionSelected: $authStateEnvObject.transactionSegment, label: "Мои Задания")
                .onTapGesture {
                    authStateEnvObject.transactionSegment.toggle()
                    generator.prepare()
                    generator.impactOccurred()
                }
                .allowsHitTesting(authStateEnvObject.transactionSegment != .upcoming)
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
            Text(NamingEnum.noTransactions.name)
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
