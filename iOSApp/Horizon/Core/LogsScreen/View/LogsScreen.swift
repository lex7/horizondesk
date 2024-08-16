//
//  LogsScreen.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 09.08.2024.
//

import SwiftUI

struct LogsScreen: View {
    
    // MARK: - Environment variables
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var authStateEnvObject: AuthStateEnvObject
    @Environment(\.presentationMode) private var presentationMode
    
    @Binding var logId: Int
    
    var body: some View {
        VStack {
            header
                .padding(.horizontal, 20)
                .padding(.bottom, 15)
            if authStateEnvObject.logsIsLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                if authStateEnvObject.logsModel.isEmpty {
                    messageForEmptyList
                } else {
                    List {
                        Section(
                            header:
                                HStack(spacing: 0) {
                                    Spacer()
                                }
                                .font(.footnote)
                                .foregroundColor(.orange)
                        ) {
                            ForEach(authStateEnvObject.logsModel, id: \.self) { log in
                                logCell(log)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
                
            }
        }
        .onAppear {
            authStateEnvObject.getLogs(logId)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .background(Color.theme.background)
    }
}

private extension LogsScreen {
    @ViewBuilder
    private func logCell(_ log: LogsModel) -> some View {
        VStack {
            if log.old_status_id == nil {
                HStack {
                    descriptionOfField("cтатус:", color: Color.theme.lowContrast)
                    descriptionOfField("cоздан",
                                       color: .theme.primary)
                    Spacer()
                }
            } else if let oldStatus = IssueStatus(rawValue: log.old_status_id ?? 999),
                      let newStatus = IssueStatus(rawValue: log.new_status_id),
                      oldStatus == .new && newStatus != .declined {
                HStack {
                    descriptionOfField("cтатус:", color: Color.theme.lowContrast)
                    descriptionOfField("направлен в работу",
                                       color: .theme.primary)
                    Spacer()
                }
            } else {
                HStack {
                    descriptionOfField("cтатус:", color: Color.theme.lowContrast)
                    descriptionOfField(IssueStatus(rawValue: log.new_status_id)?.descriptionIssuer ?? "",
                                       color: IssueStatus(rawValue: log.new_status_id)?.colorLogs ?? .cyan)
                    Spacer()
                }
            }
            HStack {
                descriptionOfField("время:", color: Color.theme.lowContrast)
                descriptionOfField(log.сhangedAtString, color: Color.theme.lowContrast)
                Spacer()
            }
            if let reason = log.reason {
                if !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    if log.old_status_id != nil {
                        HStack {
                            descriptionOfField("пометка:", color: Color.theme.lowContrast)
                            descriptionOfField(reason.trimmingCharacters(in: .whitespacesAndNewlines), lines: 20, color: Color.theme.lowContrast)
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

private extension LogsScreen {
    var header: some View {
        HStack {
            Text("Просмотр Логов")
                .withDefaultTextModifier(
                    font: "NexaRegular",
                    size: 16,
                    relativeTextStyle: .callout,
                    color: Color.theme.mediumContrast
                )
                .padding(.horizontal, 10)
            Spacer()
            createSysImageTitle(title: "", systemName: "xmark", imageFirst: false)
                .padding(.horizontal, 10)
                .contentShape(Rectangle())
                .onTapGesture {
                    authStateEnvObject.logsModel = []
                    presentationMode.wrappedValue.dismiss()
                }
        }
    }
}

private extension LogsScreen {
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
