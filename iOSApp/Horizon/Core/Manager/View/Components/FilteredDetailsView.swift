//
//  FilteredDetailsView.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 24.09.2024.
//

import SwiftUI

struct FilteredDetailsView: View {
    
    // MARK: - EnvironmentObject
    @EnvironmentObject private var authStateEnvObject: AuthStateEnvObject
    @Environment(\.presentationMode) private var presentationMode
    
    // MARK: - Binding
    /// BarChart
    @Binding var currentChart: [(day: Date, events: Int)]
    @Binding var scrollPositionStart: Date
    @Binding var visibleDomain: Int
    @Binding var issues: [RequestIssueModel]
    
    /// PieChart Specialization
    @Binding var specialTypeChart: [(name: String, count: Int)]
    @Binding var mostSpecialFragments: (name: String, count: Int)?
    /// PieChart Status
    @Binding var statusTypeChart: [(name: String, count: Int)]
    @Binding var mostStatusFragments: (name: String, count: Int)?
    /// PieChart Status
    @Binding var areaTypeChart: [(name: String, count: Int)]
    @Binding var mostAreaFragments: (name: String, count: Int)?
    
    var generator: UIImpactFeedbackGenerator
    
    // MARK: - Private State
    @State private var isShowDetails: Bool?
    @State private var screenHeight = UIScreen.main.bounds.height
    @State private var screenWidth = UIScreen.main.bounds.width
    @State private var currentNode: RequestIssueModel = RequestIssueModel(request_id: 1, request_type: 2,
                                                                          created_by: 99, assigned_to: nil,
                                                                          area_id: 3, description: nil,
                                                                          status_id: 99, created_at: nil,
                                                                          updated_at: nil, reason: nil)
    @State private var logId: Int  = 10000000
    
    private var scrollPositionEnd: Date {
        scrollPositionStart.addingTimeInterval(3600 * 24 * Double(visibleDomain))
    }
    
    private var scrollPositionString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMM" // Example: "31 декабря", adjust format as needed
        return formatter.string(from: scrollPositionStart)
    }
    
    private var scrollPositionEndString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMM yyyy" // Example: "31 декабря", adjust format as needed
        return formatter.string(from: scrollPositionEnd)
    }
    
    // MARK: - Private Constants

    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                HStack {
                    topLeftHeader(title: "Фильтр")
                    Spacer()
                    topRightHeaderAccount(title: "Свернуть", image: "chevron.down")
                        .onTapGesture {
                            generator.impactOccurred()
                            presentationMode.wrappedValue.dismiss()
                        }
                }
                VStack {
                    HStack {
                        Text("Найдено: \(authStateEnvObject.issuesFilteredBoss.count)")
                            .withDefaultTextModifier(font: "NexaRegular", size: 15,
                                                     relativeTextStyle: .callout, color: Color.theme.mediumContrast)
                        Spacer()
                        Text("\(scrollPositionString) – \(scrollPositionEndString)")
                            .withDefaultTextModifier(font: "NexaRegular", size: 15,
                                                     relativeTextStyle: .callout, color: Color.theme.mediumContrast)
                    }
                        .padding(.top, 15)
                    DailySalesChart(scrollPosition: $scrollPositionStart,
                                    dataForChart: $currentChart,
                                    visibleDomain: $visibleDomain)
                    .frame(height: 190)
                    .padding(.top, 15)
                    if let mostSpecialFragments = mostSpecialFragments {
                        DisclosureGroup {
                            TypeSpecPieChart(data: specialTypeChart, topSpec: mostSpecialFragments,
                                             totalAmount: authStateEnvObject.issuesFilteredBoss.count,
                                             generator: generator)
                                .padding(.horizontal, 20)
                        } label: {
                            HStack {
                                makeMediumContrastView(text: "Категория заявок", image: "chart.pie", imageFirst: true)
//                                Text("Категория заявок")
//                                    .withDefaultTextModifier(font: "NexaRegular", size: 16,
//                                                             relativeTextStyle: .footnote,
//                                                             color: Color.theme.mediumContrast)
                            }
                            .padding(.top, 10)
                            .padding(.horizontal, 10)
                        }
                        //.foregroundColor(Color.theme.mediumContrast)
                        .tint(Color.theme.mediumContrast)
                        .padding(.top, 5)
                    }
                    
                    if let mostStatusFragments = mostStatusFragments {
                        DisclosureGroup {
                            TypeSpecPieChart(data: statusTypeChart, topSpec: mostStatusFragments,
                                             totalAmount: authStateEnvObject.issuesFilteredBoss.count,
                                             generator: generator)
                                .padding(.horizontal, 20)
                        } label: {
                            HStack {
                                makeMediumContrastView(text: "Статус заявок", image: "chart.pie", imageFirst: true)
                            }
                            .padding(.top, 10)
                            .padding(.horizontal, 10)
                        }
                        .foregroundColor(Color.theme.mediumContrast)
                        .padding(.top, 5)
                        
                    }
                    if let mostAreaFragments = mostAreaFragments {
                        DisclosureGroup {
                            TypeSpecPieChart(data: areaTypeChart, topSpec: mostAreaFragments,
                                             totalAmount: authStateEnvObject.issuesFilteredBoss.count,
                                             generator: generator)
                                .padding(.horizontal, 20)
                        } label: {
                            HStack {
                                makeMediumContrastView(text: "Заявки по участкам", image: "chart.pie", imageFirst: true)
                            }
                            .padding(.top, 10)
                            .padding(.horizontal, 10)
                        }
                        .foregroundColor(Color.theme.mediumContrast)
                        .padding(.top, 5)
                        
                    }
                    ForEach(authStateEnvObject.issuesFilteredBoss, id: \.self) { issue in
                        issueCellFor(issue)
                            .onTapGesture {
                                currentNode = issue
                                logId = issue.request_id
                                isShowDetails = true
                            }
                    }
                            .padding(.top, 10)
                }
                .padding(.horizontal, 20)
            } /// End Of ScrollView
        } /// End of VStack
        .sheet(item: $isShowDetails, onDismiss: {
            authStateEnvObject.logsModel = []
        }, content: { _ in
            ManagerRequestDetailLogView(currentNode: $currentNode, logId: $logId)
        })
    }
}

private extension FilteredDetailsView {
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
                switch authStateEnvObject.issueRequestSegment {
                case .masterReview:
                    titleHeader(issue.description ?? "", color: .highContrast, uppercase: false)
                case .done:
                    titleHeader(issue.description ?? "", color: .theme.positivePrimary, uppercase: false)
                case .declined:
                    titleHeader(issue.description ?? "", color: .theme.negativePrimary, uppercase: false)
                }
            }
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
            switch status {
            case .new:
                HStack(spacing: 3) {
                    descriptionOfField("создано:", color: Color.theme.lowContrast)
                    descriptionOfField(issue.createdAtString, color: Color.theme.lowContrast)
                }
            case .approved:
                HStack(spacing: 3) {
//                    descriptionOfField("направлен:", color: Color.theme.lowContrast)
                    descriptionOfField(issue.updatedAtString, color: Color.theme.lowContrast)
                }
            case .inprogress:
                HStack(spacing: 3) {
                    //descriptionOfField("начат:", color: Color.theme.lowContrast)
                    descriptionOfField(issue.updatedAtString, color: Color.theme.lowContrast)
                }
            case .review:
                HStack {
                    descriptionOfField(issue.updatedAtString, color: Color.theme.lowContrast)
                }
            case .done:
                HStack {
                    descriptionOfField(issue.updatedAtString, color: Color.theme.lowContrast)
                }
            case .declined:
                HStack(spacing: 3) { // completed ??
                    descriptionOfField(issue.updatedAtString, color: Color.theme.lowContrast)
                }
            }
        } else {
            EmptyView()
        }
    }
}
