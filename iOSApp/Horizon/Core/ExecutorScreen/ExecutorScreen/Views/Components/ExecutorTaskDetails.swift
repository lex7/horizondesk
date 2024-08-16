//
//  ExecutorTaskDetails.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 06.08.2024.
//

import SwiftUI

struct ExecutorTaskDetails: View {
    
    // MARK: - Environment variables
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var authStateEnvObject: AuthStateEnvObject

    // MARK: - Private Variables
    @State private var describeStateLoadingOrError = "Loading history transactions"

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
                defaultSpacer
                titleAndValueMultiLines(title: "Комментарий", value: reason, lines: 30, maxWidth: 1)
                    .padding(.horizontal, 28)
            }
            monsterSpacer
            doubleSpacer
            Spacer()
            HStack {
                makeMediumContrastView(text: "Назад", image: "xmark", imageFirst: true)
                    .padding(.horizontal, 30)
                    .onTapGesture {
                        generator.impactOccurred()
                        presentationMode.wrappedValue.dismiss()
                    }
                Spacer()
                makeMediumContrastView(text: "Взять в работу", image: "checkmark", imageFirst: false, color: .positivePrimary)
                    .padding(.horizontal, 30)
                    .onTapGesture {
                        generator.impactOccurred()
                        authStateEnvObject.executerTakeOnWork(currentNode.request_id) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
            }
            .padding(.bottom, screenHeight/20)
        }
        .background(
            colorScheme == .dark ? Color.gradient.bkGradientDarkToExtraLowContrast : Color.gradient.bkGradientLightToExtraLowContrast
        )
    }
}

private extension ExecutorTaskDetails {
    
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

