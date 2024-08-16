//
//  ExecutorTaskDetails.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 06.08.2024.
//

import SwiftUI

struct ExecutorMyTaskDetails: View {
    
    // MARK: - Environment variables
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var authStateEnvObject: AuthStateEnvObject
    
    // MARK: - Private Variables
    @State private var describeStateLoadingOrError = "Loading history transactions"
    @State private var tfMinHeight: CGFloat = 45
    @State private var taskJastification: String = ""
    @FocusState private var isFocused: Bool
    
    // MARK: - Private Constants
    @State private var screenHeight = UIScreen.main.bounds.height
    private let generator = UIImpactFeedbackGenerator(style: .light)
    
    @Binding var currentNode: RequestIssueModel
    
    var body: some View {
        ScrollView {
            VStack {
                // 1. Amount - Status - Sub Status
                defaultSpacer
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
                if let reason = currentNode.reason {
                    defaultSpacer
                    titleAndValueMultiLines(title: "Комментарий", value: reason, lines: 30, maxWidth: 1)
                        .padding(.horizontal, 28)
                }
                justificationTextField
                    .onTapGesture {
                        generator.prepare()
                        generator.impactOccurred()
                        isFocused = true
                    }
                    .padding(.top, 20)
                Spacer()
            }
        }
        .overlay {
            if !isFocused {
                VStack {
                    Spacer()
                    bottomButtons
                        .padding(.bottom, 20)
                }
            }
        }
        .background(
            colorScheme == .dark ? Color.gradient.bkGradientDarkToExtraLowContrast : Color.gradient.bkGradientLightToExtraLowContrast
        )
        .onTapGesture {
            hideKeyboard()
        }
    }
}

private extension ExecutorMyTaskDetails {
    @ViewBuilder
    var justificationTextField: some View {
        if IssueStatus(rawValue: currentNode.status_id) != .done && IssueStatus(rawValue: currentNode.status_id) != .review {
            TextField("Пояснение к заявке", text: $taskJastification, axis: .vertical)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .frame(minHeight: $tfMinHeight.wrappedValue)
                .foregroundColor(.theme.highContrast)
                .lineLimit(25)
                .focused($isFocused)
                .submitLabel(.return)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(isFocused ? Color.theme.vibrant : Color.theme.lowContrast, lineWidth: 3)
                }
                .background(Color.theme.surface)
                .padding(.horizontal, 20)
        } else {
            EmptyView()
        }
    }
    
    var bottomButtons: some View {
        Group {
            HStack {
                if IssueStatus(rawValue: currentNode.status_id) == .done &&
                    IssueStatus(rawValue: currentNode.status_id) != .review &&
                    IssueStatus(rawValue: currentNode.status_id) != .inprogress {
                    makeMediumContrastView(text: "Назад", image: "xmark", imageFirst: true)
                        .padding(.horizontal, 30)
                        .onTapGesture {
                            generator.impactOccurred()
                            presentationMode.wrappedValue.dismiss()
                        }
                } else {
                    makeMediumContrastView(text: "Отменить", image: "xmark", imageFirst: true, color: .negativePrimary)
                        .padding(.horizontal, 30)
                        .onTapGesture {
                            authStateEnvObject.executerCancel(currentNode.request_id, reason: taskJastification) {
                                Task {
                                    try await Task.sleep(nanoseconds: 200_000_000)
                                    authStateEnvObject.executorMyTasksRequest()
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                }
                Spacer()
                if IssueStatus(rawValue: currentNode.status_id) != .done && IssueStatus(rawValue: currentNode.status_id) != .review  {
                    makeMediumContrastView(text: "На проверку", image: "checkmark", imageFirst: false, color: .positivePrimary)
                        .padding(.horizontal, 30)
                        .onTapGesture {
                            debugPrint(currentNode)
                            generator.impactOccurred()
                            authStateEnvObject.executerCompleteSendReview(currentNode.request_id, reason: taskJastification) {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                }
            }
            .padding(.bottom, screenHeight/20)
        }
    }
    
    
    var defaultSpacer: some View {
        Spacer()
            .frame(width: 10, height: 28)
            .background(Color.clear)
    }
}

