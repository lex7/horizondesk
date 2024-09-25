//
//  ManagerRequestDetailLog.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 25.09.2024.
//
import SwiftUI

struct ManagerRequestDetailLogView: View {
    
    // MARK: - Environment variables
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var authStateEnvObject: AuthStateEnvObject
    
    // MARK: - Private Variables
    @FocusState private var isFocused: Bool
    @State private var tfMinHeight: CGFloat = 45
    @State private var screenWidth = UIScreen.main.bounds.width
    
    // MARK: - Private Constants
    @State private var screenHeight = UIScreen.main.bounds.height
    private let generator = UIImpactFeedbackGenerator(style: .light)
    
    @Binding var currentNode: RequestIssueModel
    @Binding var logId: Int
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Group {
                    // 1. Amount - Status - Sub Status
                    defaultSpacer
                    HStack {
                        Spacer()
                        topRightHeaderAccount(title: "Закрыть")
                            .onTapGesture {
                                generator.impactOccurred()
                                presentationMode.wrappedValue.dismiss()
                            }
                    }
                    Divider()
                    defaultSpacer
                    // 2. Date Block
                    dateTitleAndValue(title: "Дата создания", value: currentNode.createdAtString)
                    defaultSpacer
                    // 3. Transaction TypeName Block
                    titleAndValue(title: "Cпециализация", value: RequestTypeEnum(rawValue: currentNode.request_type)?.name ?? "" )
                    defaultSpacer
                    Divider()
                    defaultSpacer
                    // 3. Transaction ID Block
                    titleAndValue(title: "Участок", value: RegionIssue(rawValue: currentNode.area_id)?.name ?? "")
                    defaultSpacer
                    titleAndValueMultiLines(title: "Текст заявки", value: currentNode.description ?? "", lines: 20, maxWidth: 1)
                        .padding(.horizontal, 28)
                    Divider()
                        .padding(.vertical, 10)
                    HStack {
                        makeMediumContrastView(text: "История", image: "doc.plaintext", imageFirst: false)
                        Spacer()
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 10)
                    listOfLogs
                }
            } /// end of Vstack
        } /// end of ScrollView
        .background(
            colorScheme == .dark ? Color.gradient.bkGradientDarkToExtraLowContrast : Color.gradient.bkGradientLightToExtraLowContrast
        )
        .onTapGesture {
            hideKeyboard()
        }
    }
}

private extension ManagerRequestDetailLogView {
    var listOfLogs: some View {
        VStack(spacing: 0) {
            if authStateEnvObject.logsIsLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                if authStateEnvObject.logsModel.isEmpty {
                    messageForEmptyList
                } else {
                    List {
                        ForEach(authStateEnvObject.logsModel, id: \.self) { log in
                            logCell(log)
                                .listRowBackground(Color.theme.background)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .background(ignoresSafeAreaEdges: .all)
                }
            }
        } /// End of Vstack
        .onAppear {
            Task {
                try await Task.sleep(nanoseconds: 200_000_000)
                authStateEnvObject.getLogs(logId)
            }
        }
    }
}

private extension ManagerRequestDetailLogView {
    @ViewBuilder
    private func logCell(_ log: LogsModel) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        descriptionOfField("cтатус:", color: Color.theme.lowContrast)
                    }
                    HStack(spacing: 0) {
                        descriptionOfField("время:", color: Color.theme.lowContrast)
                    }
                    HStack(spacing: 0) {
                        descriptionOfField("имя:", color: Color.theme.lowContrast)
                    }
                    if let reason = log.reason {
                        if !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            if log.old_status_id != nil {
                                HStack {
                                    descriptionOfField("пометка:", color: Color.theme.lowContrast)
                                }
                            }
                        }
                    }
                }
                .frame(width: screenWidth/7)
                VStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        descriptionOfField(log.action_name,
                                           color: IssueStatus(rawValue: log.new_status_id)?.colorLogs ?? .cyan)
                    }
                    HStack(spacing: 0) {
                        descriptionOfField(log.сhangedAtString, color: Color.theme.lowContrast)
                    }
                    HStack(spacing: 0) {
                        descriptionOfField(log.changer_name, color: Color.theme.lowContrast)
                    }
                    HStack(spacing: 0) {
                        if let reason = log.reason {
                            if !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                if log.old_status_id != nil {
                                    HStack(spacing: 0) {
                                        descriptionOfField(reason.trimmingCharacters(in: .whitespacesAndNewlines), lines: 20, color: Color.theme.lowContrast)
                                    }
                                }
                            }
                        }
                    }
                }
                VStack {
                    Spacer()
                }
                .background(.orange)
            }
            .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                return viewDimensions[.listRowSeparatorLeading] - 10
            }
        } // End of Vstack Cell
    }
}


private extension ManagerRequestDetailLogView {
    @ViewBuilder
    private var messageForEmptyList: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
            Text(NamingEnum.noLogsFound.name)
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



private extension ManagerRequestDetailLogView {
    var defaultSpacer: some View {
        Spacer()
            .frame(width: 10, height: 24)
            .background(Color.clear)
    }
}

