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
    @State private var screenWidth = UIScreen.main.bounds.width
    
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
                if authStateEnvObject.logsModel.isEmpty && !authStateEnvObject.logsIsLoading {
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
                    Spacer()
                }
            }
        }
        .onAppear {
            Task {
                try await Task.sleep(nanoseconds: 200_000_000)
                authStateEnvObject.getLogs(logId)
            }
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
            HStack(spacing: 0) {
                VStack(alignment: .leading) {
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


private extension LogsScreen {
    var header: some View {
        HStack {
            Text("Просмотр истории")
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
