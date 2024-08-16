//  Created by Timofey Privalov MobileDesk
import SwiftUI

struct MasterScreen: View {
    
    // MARK: - Environment variables
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var authStateEnvObject: AuthStateEnvObject

    // MARK: - Private State Variables
    @State private var masterSegment: MasterSwitcher = .underMasterApproval
    @State private var showIssueConfirm: Bool?
    @State private var screenHeight = UIScreen.main.bounds.height
    @State private var currentNode: RequestIssueModel = RequestIssueModel(request_id: 1, request_type: 2, created_by: 99, assigned_to: nil, area_id: 3, description: nil, status_id: 99, created_at: nil, updated_at: nil, reason: nil)
    
    // MARK: - Private Constants
    private let generator = UIImpactFeedbackGenerator(style: .light)
    
    
    // MARK: - Binding Variables
    @Binding var tabSelection: TabBarItem
    
    var body: some View {
        VStack {
            HStack {
                topLeftHeader(title: "На Рассмотрение")
                Spacer()
            }
            HStack {
                pickerContainer
                    .padding(.horizontal, 12)
                    .background(Color.theme.background)
            }
            .frame(maxWidth: .infinity)
            switch masterSegment {
            case .underMasterApproval:
                if authStateEnvObject.masterIsLoading {
                    Spacer()
                    ProgressView()
                } else {
                    if authStateEnvObject.requestsForMaster.isEmpty {
                        messageForEmptyList
                    } else {
                        masterApproval
                    }
                }
                Spacer()
            case .masterMonitor:
                if authStateEnvObject.masterIsLoading {
                    Spacer()
                    ProgressView()
                } else {
                    if authStateEnvObject.requestsForMasterMonitor.isEmpty {
                        messageForEmptyList
                    } else {
                        masterMonitor
                    }
                }
                Spacer()
            }
        }
        .sheet(item: $showIssueConfirm, onDismiss: {
            authStateEnvObject.getRequestsForMaster()
            authStateEnvObject.getRequestsForMasterMonitor()
        }, content: { _ in
            IssueAcceptanceCheck(currentNode: $currentNode)
        })
//        .fullScreenCover(item: $showIssueConfirm, onDismiss: {
//            authStateEnvObject.getRequestsForMaster()
//        }, content: { _ in
//            IssueAcceptanceCheck(currentNode: $currentNode)
//        })
        .background(Color.theme.background)
        .onChange(of: tabSelection) {
            if tabSelection == .masterReviewIssue {
                authStateEnvObject.getRequestsForMaster()
                authStateEnvObject.getRequestsForMasterMonitor()
            }
        }
    }
}

#Preview {
    MasterScreen(tabSelection: .constant(.masterReviewIssue))
}

private extension MasterScreen {
    var pickerContainer: some View {
        HStack(alignment: .center, spacing: 4) {
            MasterLeftSegmentView(sectionSelected: $masterSegment, label: "На рассмотрение")
                .onTapGesture {
                    masterSegment.toggle()
                    generator.prepare()
                    generator.impactOccurred()
                }
                .allowsHitTesting(masterSegment != .underMasterApproval)
            MasterRightSegmentView(sectionSelected: $masterSegment, label: "Мониторинг")
                .onTapGesture {
                    masterSegment.toggle()
                    generator.prepare()
                    generator.impactOccurred()
                }
                .allowsHitTesting(masterSegment != .masterMonitor)
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

private extension MasterScreen {
    var masterApproval: some View {
        ScrollView {
            ForEach(authStateEnvObject.requestsForMaster, id: \.self) { issue in
                issueCellFor(issue)
                    .onTapGesture {
                        currentNode = issue
                        showIssueConfirm = true
                    }
            }
        }
        .padding(.bottom, screenHeight/16)
    }
    
    var masterMonitor: some View {
        ScrollView {
            ForEach(authStateEnvObject.requestsForMasterMonitor, id: \.self) { issue in
                issueCellFor(issue)
                    .onTapGesture {
                        currentNode = issue
                        showIssueConfirm = true
                    }
            }
        }
        .padding(.bottom, screenHeight/16)
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
    func issueCellFor(_ issue: RequestIssueModel) -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                titleHeader(RequestTypeEnum(rawValue: issue.request_type)?.name ?? "",
                            lines: 3)
                Spacer()
                descriptionOfField(RegionIssue(rawValue: issue.area_id)?.name ?? "",
                                   color: Color.theme.secondary)
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
                switch authStateEnvObject.issueRequestSegment {
                case .masterReview:
                    titleHeader(issue.description ?? "", color: .vibrant, uppercase: false)
                case .done:
                    titleHeader(issue.description ?? "", color: .theme.muted, uppercase: false)
                case .declined:
                    titleHeader(issue.description ?? "", color: .theme.negativePrimary, uppercase: false)
                }
            }
            .padding(.top, 10)
            switch authStateEnvObject.issueRequestSegment {
            case .masterReview:
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
    private func createDateString(_ issue: RequestIssueModel) -> some View {
        if let status = issue.statusOfElement {
            switch status {
            case .new:
                HStack(spacing: 3) {
                    descriptionOfField("создано:", color: Color.theme.lowContrast)
                    descriptionOfField(issue.createdAtString, color: Color.theme.lowContrast)
                }
            default:
                HStack(spacing: 3) {
                    descriptionOfField("обновлено:", color: Color.theme.lowContrast)
                    descriptionOfField(issue.updatedAtString, color: Color.theme.lowContrast)
                }
            }
        } else {
            EmptyView()
        }
    }
}

private extension MasterScreen {
    @ViewBuilder
    private var messageForEmptyList: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
            Text(NamingEnum.noReview.name)
                .withDefaultTextModifier(font: "NexaRegular", size: 16, relativeTextStyle: .callout, color: Color.theme.lowContrast)
            Text(NamingTextEnum.emptyScreenDebts.name)
                .lineLimit(8)
                .lineSpacing(5)
                .multilineTextAlignment(.leading)
                .withDefaultTextModifier(font: "NexaRegular", size: 13, relativeTextStyle: .footnote, color: Color.theme.lowContrast)
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}
