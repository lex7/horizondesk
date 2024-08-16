//
//  MasterMonitorScreen.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 16.08.2024.
//

import SwiftUI

struct MasterMonitorScreen: View {
    
    // MARK: - Environment variables
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var authStateEnvObject: AuthStateEnvObject
    
    // MARK: - Private Variables
    @FocusState private var isFocused: Bool
    @State private var tfMinHeight: CGFloat = 45
    // MARK: - Private Constants
    @State private var screenHeight = UIScreen.main.bounds.height
    private let generator = UIImpactFeedbackGenerator(style: .light)
    
    @Binding var currentNode: RequestIssueModel
    
    var body: some View {
        ScrollView {
            VStack {
                Group {
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
                        .padding(.bottom, 20)
                }
                defaultSpacer
                defaultSpacer
                defaultSpacer
                defaultSpacer
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

private extension MasterMonitorScreen {
        
    var defaultSpacer: some View {
        Spacer()
            .frame(width: 10, height: 28)
            .background(Color.clear)
    }
    
}

