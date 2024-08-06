//  Created by Timofey Privalov MobileDesk
import SwiftUI
import SwiftfulRouting

struct MonitorIssueScreen: View {
    
    // MARK: - Environment variables
    @EnvironmentObject private var authStateEnvObject: AuthStateEnvObject
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.router) var router
    private let generator = UIImpactFeedbackGenerator(style: .light)
    // MARK: - Binding Variables
    @Binding var tabSelection: TabBarItem
    
    // MARK: - Private State Variables
    @State private var showDetails = false
    @State private var showNeedActionDetails = false
    @State private var forwardToTransaction = false
    @State private var screenHeight = UIScreen.main.bounds.height
    @State private var screenWidth = UIScreen.main.bounds.width
    
    // MARK: - Private Constants
    private var columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 16), count: 1)
    
    init(tabSelection: Binding<TabBarItem>) {
        self._tabSelection = tabSelection
    }
    
    var body: some View {
        VStack {
            HStack {
                topLeftHeader(title: "Мои Заявки")
                Spacer()
            } // End HStack - Logo
            .offset(y: -5)
            HStack {
                pickerContainer
                    .padding(.horizontal, 12)
                    .background(Color.theme.background)
            }
            Group {
                switch authStateEnvObject.issueDebtSegment {
                case .inProgress:
                    switch authStateEnvObject.issuesInWork.isEmpty {
                    case true:
                        ScrollView(.vertical, showsIndicators: false) {
                            messageForEmptyList
                                .padding(.top, screenHeight/4)
                        }
                    case false:
                        inProgressIssue
                            .padding(.bottom, screenHeight/11)
                            .transition(.asymmetric(insertion: .slide, removal: .move(edge: .leading)))
                    }
                case .done:
                    switch authStateEnvObject.issuesDone.isEmpty {
                    case true:
                        ScrollView(.vertical, showsIndicators: false) {
                            messageForEmptyList
                                .padding(.top, screenHeight/4)
                        }
                    case false:
                        doneIssues
                            .padding(.bottom, screenHeight/11)
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .slide))
                    }
                    // FIXME: - Need appropriate cells
                case .declined:
                    switch authStateEnvObject.issuesDeclined.isEmpty {
                    case true:
                        ScrollView(.vertical, showsIndicators: false) {
                            messageForEmptyList
                                .padding(.top, screenHeight/4)
                        }
                    case false:
                        declinedIssues
                            .padding(.bottom, screenHeight/11)
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .slide))
                    }
                }
            }
            .animation(.easeInOut, value: authStateEnvObject.issueDebtSegment)
            .padding(.top, 5)
            .padding(.top, 2)
            .onAppear {
                authStateEnvObject.getInProgressIssue()
                authStateEnvObject.getInProgressIssue()
                authStateEnvObject.getDeniedIssue()
            }
            .onChange(of: tabSelection) { value in
                if tabSelection == .monitorIssue {
                    authStateEnvObject.getInProgressIssue()
                    authStateEnvObject.getInProgressIssue()
                    authStateEnvObject.getDeniedIssue()
                }
            }
            .onChange(of: authStateEnvObject.issueDebtSegment) { value in
                authStateEnvObject.getInProgressIssue()
                authStateEnvObject.getInProgressIssue()
                authStateEnvObject.getDeniedIssue()
            }
            .padding(.horizontal, 12)
        }
        .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black, .black, .black, .clear]), startPoint: .top, endPoint: .bottom).ignoresSafeArea(edges: .top))
        .background(Color.theme.background)
    }
}

private extension MonitorIssueScreen {
    var inProgressIssue: some View {
        ScrollView {
            ForEach(authStateEnvObject.issuesInWork, id: \.self) { issue in
                switch issue.statusOfElement {
                case .review:
                    Menu {
                        Button("Подтвердить выполнение") {
                            generator.impactOccurred()
                            //                            authStateEnvObject.doneIssue(id: issue.request_id) {
                            //                                authStateEnvObject.getMyRequests()
                            //                            }
                        }
                        Button("Отмена") {
                            generator.impactOccurred()
                            //                            authStateEnvObject.getMyRequests()
                        }
                    } label: {
                        issueCellFor(issue)
                    }
                default:
                    issueCellFor(issue)
                }
            }
        }
    }
    
    var doneIssues: some View {
        ScrollView {
            ForEach(authStateEnvObject.issuesDone, id: \.self) { issue in
                issueCellFor(issue)
            }
        }
    }
    
    var declinedIssues: some View {
        ScrollView {
            ForEach(authStateEnvObject.issuesDeclined, id: \.self) { issue in
                issueCellFor(issue)
            }
        }
    }
}


private extension MonitorIssueScreen {
    
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
                            .foregroundStyle(issue.progressIssuerColor)
                            .frame(width: (geometry.size.width))
                    }
                }
            }
            HStack {
                switch authStateEnvObject.issueDebtSegment {
                case .inProgress:
                    titleHeader(issue.description ?? "", color: .highContrast, uppercase: false)
                case .done:
                    titleHeader(issue.description ?? "", color: .theme.positivePrimary, uppercase: false)
                case .declined:
                    titleHeader(issue.description ?? "", color: .theme.negativePrimary, uppercase: false)
                }
            }
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
    private func createDateString(_ issue: RequestIssueModel) -> some View {
        if let status = issue.statusOfElement {
            EmptyView()
            //            switch status {
            //            case .new:
            //                HStack(spacing: 3) {
            //                    descriptionOfField("создано:", color: Color.theme.lowContrast)
            //                    descriptionOfField(issue.created_at.getTimeHorizon(), color: Color.theme.lowContrast)
            //                }
            //            case .approved:
            //                HStack(spacing: 3) {
            //                    descriptionOfField("до:", color: Color.theme.lowContrast)
            //                    descriptionOfField(issue.deadline.getDateHorizon(), color: Color.theme.lowContrast)
            //                }
            //            case .declined:
            //                HStack(spacing: 3) {
            //                    descriptionOfField(issue.completed.getTimeHorizon(), color: Color.theme.lowContrast)
            //                }
            //            case .inprogress:
            //                HStack(spacing: 3) {
            //                    descriptionOfField("до:", color: Color.theme.lowContrast)
            //                    descriptionOfField(issue.deadline.getDateHorizon(), color: Color.theme.lowContrast)
            //                }
            //            case .review:
            //                HStack {
            //                    descriptionOfField(issue.deadline.getDateHorizon(), color: Color.theme.lowContrast)
            //                }
            //            case .done:
            //                HStack {
            //                    descriptionOfField(issue.completed.getDateHorizon(), color: Color.theme.lowContrast)
            //                }
            //            }
        } else {
            EmptyView()
        }
    }
}

private extension MonitorIssueScreen {
    var pickerContainer: some View {
        HStack(alignment: .center, spacing: 4) {
            MonitorPickerView(sectionSelected: $authStateEnvObject.issueDebtSegment, label: "В работе")
                .frame(maxWidth: (screenWidth/4), alignment: .leading)
                .onTapGesture {
                    authStateEnvObject.issueDebtSegment = .inProgress
                    authStateEnvObject.getInProgressIssue()
                }
                .allowsHitTesting(authStateEnvObject.issueDebtSegment != .inProgress)
            MonitorDonePickerView(sectionSelected: $authStateEnvObject.issueDebtSegment, label: "Исполнены")
                .onTapGesture {
                    authStateEnvObject.issueDebtSegment = .done
                }
                .allowsHitTesting(authStateEnvObject.issueDebtSegment != .done)
            MonitorRejectedPickerView(sectionSelected: $authStateEnvObject.issueDebtSegment, label: "Отклонены")
                .onTapGesture {
                    authStateEnvObject.issueDebtSegment = .declined
                }
                .allowsHitTesting(authStateEnvObject.issueDebtSegment != .declined)
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

private extension MonitorIssueScreen {
    @ViewBuilder
    private var messageForEmptyList: some View {
        switch authStateEnvObject.issueDebtSegment {
        case .inProgress:
            VStack(alignment: .leading, spacing: 20) {
                Text(NamingEnum.noRequests.name)
                    .withDefaultTextModifier(font: "NexaRegular", size: 16, relativeTextStyle: .callout, color: Color.theme.lowContrast)
                Text(NamingTextEnum.emptyScreenDebts.name)
                    .lineLimit(8)
                    .lineSpacing(5)
                    .multilineTextAlignment(.leading)
                    .withDefaultTextModifier(font: "NexaRegular", size: 13, relativeTextStyle: .footnote, color: Color.theme.lowContrast)
            }
            .padding(.horizontal, 24)
        case .done:
            VStack(alignment: .leading, spacing: 20) {
                Text(NamingEnum.noRequests.name)
                    .withDefaultTextModifier(font: "NexaRegular", size: 16, relativeTextStyle: .callout, color: Color.theme.lowContrast)
                Text(NamingTextEnum.emptyScreenDebtsDone.name)
                    .lineLimit(8)
                    .lineSpacing(5)
                    .multilineTextAlignment(.leading)
                    .withDefaultTextModifier(font: "NexaRegular", size: 13, relativeTextStyle: .footnote, color: Color.theme.lowContrast)
            }
            .padding(.horizontal, 24)
        case .declined:
            VStack(alignment: .leading, spacing: 20) {
                Text(NamingEnum.noRequests.name)
                    .withDefaultTextModifier(font: "NexaRegular", size: 16, relativeTextStyle: .callout, color: Color.theme.lowContrast)
                Text(NamingTextEnum.emptyScreenDebtsNeedAction.name)
                    .lineLimit(8)
                    .lineSpacing(5)
                    .multilineTextAlignment(.leading)
                    .withDefaultTextModifier(font: "NexaRegular", size: 13, relativeTextStyle: .footnote, color: Color.theme.lowContrast)
            }
            .padding(.horizontal, 24)
        }
    }
}
