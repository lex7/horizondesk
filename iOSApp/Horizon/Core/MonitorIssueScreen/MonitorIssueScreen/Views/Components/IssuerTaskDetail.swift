//
//  IssuerTaskDetail.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 04.09.2024.
//

import SwiftUI

struct IssuerTaskDetail: View {
    
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
                if !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    defaultSpacer
                    titleAndValueMultiLines(title: "Комментарий", value: reason, lines: 30, maxWidth: 1)
                        .padding(.horizontal, 28)
                }
            }
            defaultSpacer
            justificationTextField
                .onTapGesture {
                    generator.prepare()
                    generator.impactOccurred()
                    isFocused = true
                }
            monsterSpacer
            doubleSpacer
            Spacer()
        } // End of VStack
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

private extension IssuerTaskDetail {
    
    @ViewBuilder
    var justificationTextField: some View {
        if IssueStatus(rawValue: currentNode.status_id) == .review {
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
    
    @ViewBuilder
    var bottomButtons: some View {
        switch currentNode.statusOfElement {
        case .new, .approved, .inprogress, .done, .declined:
            HStack {
                makeMediumContrastView(text: "Закрыть", image: "xmark", imageFirst: true)
                    .padding(.horizontal, 30)
                    .onTapGesture {
                        generator.impactOccurred()
                        Task {
                            try await Task.sleep(nanoseconds: 100_000_000)
                            authStateEnvObject.getInProgressIssue()
                            try await Task.sleep(nanoseconds: 200_000_000)
                            authStateEnvObject.getCompletedIssue()
                            try await Task.sleep(nanoseconds: 150_000_000)
                            authStateEnvObject.getDeniedIssue()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                Spacer()
            }
            .padding(.bottom, screenHeight/25)
        default:
            Group {
                HStack {
                    makeMediumContrastView(text: "Вернуть", image: "xmark", imageFirst: true, color: .negativePrimary)
                        .padding(.horizontal, 30)
                        .onTapGesture {
                            generator.impactOccurred()
                            authStateEnvObject.requesterDeniedCompletion(request_id: currentNode.request_id,
                                                                         reason: taskJastification) {
                                Task {
                                    try await Task.sleep(nanoseconds: 400_000_000)
                                    authStateEnvObject.getInProgressIssue()
                                    authStateEnvObject.getCompletedIssue()
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                        .contentShape(Rectangle())
                        .allowsHitTesting(!authStateEnvObject.isRequesterDeniedProgress)
                    Spacer()
                    makeMediumContrastView(text: "Подтвердить", image: "xmark", imageFirst: true, color: .positivePrimary)
                        .padding(.horizontal, 30)
                        .onTapGesture {
                            generator.impactOccurred()
                            authStateEnvObject.requestDone(request_id: currentNode.request_id,
                                                           reason: taskJastification) {
                                Task {
                                    try await Task.sleep(nanoseconds: 750_000_000)
                                    authStateEnvObject.getInProgressIssue()
                                    authStateEnvObject.getCompletedIssue()
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                        .contentShape(Rectangle())
                        .allowsHitTesting(!authStateEnvObject.isRequesterDeniedProgress)
                }
                .padding(.bottom, screenHeight/25)
            }
        }
    }
    
    var defaultSpacer: some View {
        Spacer()
            .frame(width: 10, height: 28)
            .background(Color.clear)
    }
    
    var doubleSpacer: some View {
        Spacer()
            .frame(width: 10, height: 56)
            .background(Color.clear)
    }
    
    var monsterSpacer: some View {
        Spacer()
            .frame(width: 10, height: 84)
            .background(Color.clear)
    }
}

