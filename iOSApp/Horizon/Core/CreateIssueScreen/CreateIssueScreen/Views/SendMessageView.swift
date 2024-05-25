//  Created by Timofey Privalov on 25.03.2024.
import SwiftUI

enum SendMessageFocus: Hashable {
    case title
    case area
    case message
}

struct SendMessageView: View {
    
    // MARK: - Private Environment variables
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentationMode) private var presentationMode
    @StateObject var vm = EnvSupportObj()
    
    // MARK: - Private Constants
    private let generator = UIImpactFeedbackGenerator(style: .light)
    @State private var screenHeight = UIScreen.main.bounds.height
    
    // MARK: - Private FocusState
    
    @FocusState private var focusedField: SendMessageFocus?
    
    // MARK: - Private State variables
    @State private var titleOfIssue: String = ""
    @State private var areaOfIssueNumber: String = ""
    @State private var inputTextIssue: String = ""
var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                titleMessage
                    .padding(.horizontal, 14)
                    .padding(.top, screenHeight/25)
                Divider()
                    .padding(.vertical, 10)
                menuIssueTheme
                areaIssue
                    .padding(.top, 20)
                customTextEditor
                    .frame(height: screenHeight/3.6)
                    .padding(.top, screenHeight/30)
                Spacer()
                sendMessage
                    .padding(.vertical, screenHeight/12)
                    .onTapGesture {
                        vm.sendIssues {
                            debugPrint(vm.areaOfIssueNumber, vm.issueTheme, vm.issueMessage)
                        }
                    }
            }
            .alert("Заявка успешно создана", isPresented: $vm.isIssueCreated) {
                // Buttons as actions for the alert
                Button("Ok", role: .cancel) {
                    titleOfIssue = ""
                    inputTextIssue = ""
                    areaOfIssueNumber = ""
                    
                }
            } message: {
                Text("Ваша заявка отправлена на рассмотрение. Благодарим!")
            }
            .padding(.horizontal, 15)
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
}

private extension SendMessageView {
    
    var sendMessage: some View {
        HStack (spacing: 0) {
            Spacer()
            makeMediumContrastView(text: "Отправить заявку", image: "paperplane", imageFirst: false)
                .padding(.horizontal, 10)
                .contentShape(Rectangle())
                .onTapGesture {
                    vm.issueMessage = inputTextIssue
                    generator.impactOccurred()
                    vm.sendIssues {
                        
                    }
                }
        }
    }
var customTextEditor: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    if #available(iOS 16, *) {
                        TextEditor(text: $inputTextIssue)
                            .foregroundColor(Color.theme.selected)
                            .tint(Color.theme.selected)
                            .scrollContentBackground(.hidden)
                            .background(.surface)
                            .cornerRadius(8)
                            .lineSpacing(10)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .padding(.horizontal, 10)
                    } else {
                        TextEditor(text: $inputTextIssue)
                            .foregroundColor(Color.theme.selected)
                            .accentColor(Color.theme.selected)
                            .background(.surface)
                            .cornerRadius(8)
                            .lineSpacing(10)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .padding(.horizontal, 10)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.theme.extraLowContrast, lineWidth: 2)
                )
                .overlay {
                    if inputTextIssue.isEmpty {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Текст обращения")
                                    .withDefaultTextModifier(font: "NexaRegular", size: 17, relativeTextStyle: .body, color: Color.theme.secondary)
                                    .padding()
                                Spacer()
                            }
                            Spacer()
                        }
                        
                    }
                }
                .background(.surface)
            }
        }
    }
    
    var menuIssueTheme: some View {
        HStack {
            // Wrapping Text inside Menu to show options on tap
            Menu {
                Button(SpecializationIssue.tools.name) {
                    vm.issueTheme = SpecializationIssue.tools.name
                    titleOfIssue = SpecializationIssue.tools.name
                }
                Button(SpecializationIssue.docs.name) {
                    vm.issueTheme = SpecializationIssue.docs.name
                    titleOfIssue = SpecializationIssue.docs.name
                }
                Button(SpecializationIssue.sanpin.name) {
                    vm.issueTheme = SpecializationIssue.sanpin.name
                    titleOfIssue = SpecializationIssue.sanpin.name
                }
                Button(SpecializationIssue.safety.name) {
                    vm.issueTheme = SpecializationIssue.safety.name
                    titleOfIssue = SpecializationIssue.safety.name
                }
                Button(SpecializationIssue.empty.name) {
                    vm.issueTheme = SpecializationIssue.empty.name
                    titleOfIssue = SpecializationIssue.empty.name
                }
            } label: {
                textViewOnBoard($titleOfIssue, focusField: .title)
            }
            Spacer()
        }
    }
var areaIssue: some View {
        HStack {
            // Wrapping Text inside Menu to show options on tap
            Menu {
                Button(RegionIssue.areaOne.name) {
                    vm.areaOfIssueNumber = RegionIssue.areaOne.name
                    areaOfIssueNumber = RegionIssue.areaOne.name
                }
                Button(RegionIssue.areaTwo.name) {
                    vm.areaOfIssueNumber = RegionIssue.areaTwo.name
                    areaOfIssueNumber = RegionIssue.areaTwo.name
                }
                Button(RegionIssue.areaThree.name) {
                    vm.areaOfIssueNumber = RegionIssue.areaThree.name
                    areaOfIssueNumber = RegionIssue.areaThree.name
                }
                Button(RegionIssue.areaFour.name) {
                    vm.areaOfIssueNumber = RegionIssue.areaFour.name
                    areaOfIssueNumber = RegionIssue.areaFour.name
                }
                Button(RegionIssue.empty.name) {
                    vm.areaOfIssueNumber = RegionIssue.empty.name
                    areaOfIssueNumber = RegionIssue.empty.name
                }
            } label: {
                textViewOnBoard($areaOfIssueNumber, placeHolder: "Выберите участок", focusField: .area)
            }
            Spacer()
        }
    }

    var titleMessage: some View {
        HStack {
            Text("Создание заявки")
                .withDefaultTextModifier(font: "NexaBold", size: 20, relativeTextStyle: .title3, color: .highContrast)
            Spacer()
        }
    }
    
    var dragIndicator: some View {
        HStack {
            Spacer()
            dragIndicator()
            Spacer()
        }
    }
@ViewBuilder
    func textViewOnBoard(
        _ txt: Binding<String>,
        secure: Bool = false,
        placeHolder: String = "Cпециализация",
        focusField: SendMessageFocus,
        numPad: Bool = false
    ) -> some View {
        ZStack(alignment: .leading) {
            if txt.wrappedValue.isEmpty {
                Text(placeHolder)
                    .withDefaultTextModifier(font: "NexaRegular", size: 17, relativeTextStyle: .body, color: Color.theme.secondary)
                    .padding(15)
                    .offset(y: 2)
                    .zIndex(1)
            }
            HStack {
                Group {
                    if secure {
                        SecureField("", text: txt)
                    } else {
                        TextField("", text: txt)
                    }
                }
                .keyboardType(numPad ? .numberPad : .default)
                .focused($focusedField, equals: focusedField)
                .accentColor(Color.theme.secondary)
                .submitLabel(.done)
                .onSubmit {
                    debugPrint("\(txt)")
                }
                .foregroundColor(Color.theme.selected)
                .textFieldStyle(.plain)
                .padding([.top, .leading, .bottom], 15)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            }
            .background(Color.theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.theme.extraLowContrast, lineWidth: 2)
            )
        }
    }
}
