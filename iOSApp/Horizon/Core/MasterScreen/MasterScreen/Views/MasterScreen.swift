//  Created by Timofey Privalov MobileDesk
import SwiftUI

struct MasterScreen: View {
    
    // MARK: - Environment variables
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var authStateEnvObject: AuthStateEnvObject

    // MARK: - Private State Variables
    @State private var showIssueConfirm: Bool?
    @State private var currentNode: IssueModel = IssueModel(id: "", subject: "", message: "", region: "", status: "", created: "", deadline: "", completed: "", addedJustification: nil)
    // MARK: - Private Constants
    private let generator = UIImpactFeedbackGenerator(style: .light)
    @State private var screenHeight = UIScreen.main.bounds.height
    
    // MARK: - Binding Variables
    @Binding var tabSelection: TabBarItem
    
    var body: some View {
        VStack {
            HStack {
                topLeftHeader(title: "На Рассмотрение")
                Spacer()
            }
            allIssues
            Spacer()
        } 
        .sheet(item: $showIssueConfirm, onDismiss: {
            authStateEnvObject.getIssues()
        }, content: { _ in
            IssueAcceptanceCheck(currentNode: $currentNode)
        })
        .background(Color.theme.background)
        .onChange(of: tabSelection) { value in
            if tabSelection == .executeIssue {
                authStateEnvObject.getIssues()
            }
        }
    }
}

#Preview {
    MasterScreen(tabSelection: .constant(.executeIssue))
}

private extension MasterScreen {
    
    var allIssues: some View {
        ScrollView {
            ForEach(authStateEnvObject.issueArray, id: \.self) { issue in
                issueCellFor(issue)
                    .onTapGesture {
                        currentNode = issue
                        showIssueConfirm = true
                    }
            }
        }
        .padding(.bottom, screenHeight/11)
    }
}

private extension MasterScreen {
    
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
                            .foregroundStyle(issue.progressIssuerColor)
                            .frame(width: (geometry.size.width))
                    }
                }
            }
            HStack {
                switch authStateEnvObject.issueDebtSegment {
                case .inProgress:
                    titleHeader(issue.message, color: .highContrast, uppercase: false)
                case .done:
                    titleHeader(issue.message, color: .theme.positivePrimary, uppercase: false)
                case .declined:
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
                    createDateString(issue)
                        .padding(.top, screenHeight/120)
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.theme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.theme.extraLowContrast, lineWidth: 1)
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
