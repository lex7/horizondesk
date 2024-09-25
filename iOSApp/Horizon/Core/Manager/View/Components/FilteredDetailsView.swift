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
    @Binding var currentChart: [(day: Date, events: Int)]
    @Binding var scrollPosition: Date
    @Binding var visibleDomain: Int
    @Binding var issues: [RequestIssueModel]
    
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
    
    // MARK: - Private Constants
    private let generator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                HStack {
                    topLeftHeader(title: "Фильтр")
                    Spacer()
                    topRightHeaderAccount(title: "Закрыть")
                        .onTapGesture {
                            generator.impactOccurred()
                            presentationMode.wrappedValue.dismiss()
                        }
                }
                VStack {
                    DailySalesChart(scrollPosition: $scrollPosition,
                                    dataForChart: $currentChart,
                                    visibleDomain: $visibleDomain)
                    .frame(height: 190)
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
        .onAppear {
            authStateEnvObject.allStatsFragments = []
        }
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
