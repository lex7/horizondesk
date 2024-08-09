//
// MobileDesk
//  DeskHorizon
//
//  Created by Timofey Privalov MobileDesk
import SwiftUI

struct IssueAcceptanceCheck: View {
    
    // MARK: - Environment variables
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var authStateEnvObject: AuthStateEnvObject
    
    // MARK: - Private Variables
    @State private var taskJastification: String = ""
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
                    titleAndValueMultiLines(title: "Текст заявки", value: currentNode.description ?? "", lines: 20)
                        .padding(.horizontal, 28)
                        .padding(.bottom, 20)
                    justificationTextField
                        .onTapGesture {
                            generator.prepare()
                            generator.impactOccurred()
                            isFocused = true
                        }
                }
                Spacer()
            } /// end of Vstack
        } /// end of ScrollView
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

private extension IssueAcceptanceCheck {
    
    var justificationTextField: some View {
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
    }
    
    var bottomButtons: some View {
        Group {
            HStack {
                makeMediumContrastView(text: "Отклонить", image: "xmark", imageFirst: true)
                    .padding(.horizontal, 30)
                    .onTapGesture {
                        generator.impactOccurred()
                        authStateEnvObject.masterDenyRequest(currentNode.request_id, taskJastification) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                Spacer()
                makeMediumContrastView(text: "Подтвердить", image: "checkmark", imageFirst: false, color: .positivePrimary)
                    .padding(.horizontal, 30)
                    .onTapGesture {
                        generator.impactOccurred()
                        authStateEnvObject.masterAcceptRequest(currentNode.request_id, taskJastification) {
                            presentationMode.wrappedValue.dismiss()
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

