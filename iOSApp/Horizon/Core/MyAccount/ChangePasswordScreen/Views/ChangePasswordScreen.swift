//  Created by Timofey Privalov MobileDesk
import SwiftUI

enum PassFields: Hashable {
    case password
    case repeatPass
}

struct ChangePasswordScreen: View {
    
    // MARK: - Private Environment variables
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentationMode) private var presentationMode
    
    // MARK: View Model
    @StateObject private var vm = ChangePasswordViewModel()
@State private var password: String = ""
    @State private var repeatPassword: String = ""
    @State private var mainPassIsValid: Bool = false
    @State private var passesIsMatchAndValid: Bool = false
    @State private var repeatIsMatch: Bool = false
    
    @State private var passIsTouched: Bool = false
    @State private var repeatIsTouched: Bool = false
    @State private var isCheck8Char: Bool = false
    @State private var isCheck1lower: Bool = false
    @State private var isCheck1Upper: Bool = false
    @State private var isCheckSpecChar: Bool = false
    
    @FocusState private var focusedField: PassFields?
    
    // MARK: - Private Constants
    private let generator = UIImpactFeedbackGenerator(style: .light)
    @State private var screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        VStack {
            
            HStack {
                filterBackView
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
                Spacer()
            }
            .padding(.top, screenHeight/14)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Group {
                VStack(alignment: .leading) {
                    titleView(text: "Set up a new password")
                        .padding(.top, screenHeight/44)
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    textViewForPass(
                        $password,
                        secure: true,
                        placeHolder: "Password",
                        focusField: .password,
                        ifPassMatch: mainPassIsValid,
                        mainPass: true
                    )
                    
                    
                        .padding(.top, screenHeight/100)
                        .padding(.horizontal, 2)
                        .onTapGesture {
                            passIsTouched = true
                            focusedField = .password
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Group {
                        textViewForPass(
                            $repeatPassword,
                            secure: true,
                            placeHolder: "Repeat Password",
                            focusField: .repeatPass,
                            ifPassMatch: repeatIsMatch,
                            mainPass: false
                        )
                        .allowsHitTesting(mainPassIsValid ? true : false)
                        
                        
                        .padding(.top, screenHeight/100)
                        .padding(.horizontal, 2)
                        .onTapGesture {
                            repeatIsTouched = true
                            focusedField = .repeatPass
                        }
                        .overlay {
                            if !passesIsMatchAndValid {
                                if repeatIsTouched {
                                    descriptionOfField("passNotMatch", lines: 1, color: Color.theme.negativePrimary, big: false)
                                        .offset(x: -3, y: 23)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    VStack(alignment: .leading) {
                        Group {
                            descriptionOfField("passCheck8Char", lines: 1, color: passIsTouched ? (isCheck8Char ? Color.theme.lowContrast : Color.theme.negativePrimary) : Color.theme.lowContrast)
                                .padding(.top, screenHeight/100)
                            descriptionOfField("passCheck1lower", lines: 1, color: passIsTouched ? (isCheck1lower ? Color.theme.lowContrast : Color.theme.negativePrimary) : Color.theme.lowContrast)
                                .padding(.top, screenHeight/150)
                            descriptionOfField("passCheck1Upper", lines: 1, color: passIsTouched ? (isCheck1Upper ? Color.theme.lowContrast : Color.theme.negativePrimary) : Color.theme.lowContrast)
                                .padding(.top, screenHeight/150)
                            descriptionOfField("passCheckSpecChar", lines: 2, color: passIsTouched ? (isCheckSpecChar ? Color.theme.lowContrast : Color.theme.negativePrimary) : Color.theme.lowContrast)
                                .padding(.top, screenHeight/150)
                                .padding(.bottom, screenHeight/75)
                        }
                        
                    }
                    .padding(10)
                    Spacer()
                }
            } 
            Spacer()
            HStack {
                Spacer()
                if passesIsMatchAndValid {
                    makeMediumContrastView(text: "Set New Password", image: "checkmark", imageFirst: false)
                        .padding(.bottom, screenHeight/12)
                        .allowsHitTesting(!vm.passUpdateIsLoading)
                        .onTapGesture {
                            vm.changePass(password)
                            generator.prepare()
                            generator.impactOccurred()
                            debugPrint("[Set New Password 🟢]")
                        }
                }
            }
        } 
        .overlay {
            if vm.passUpdateIsLoading {
                ProgressView()
            }
        }
        .alert("Success", isPresented: $vm.showSuccesPassChanged) {
            Button("Ok", role: .cancel) {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Your password has been successfully changed.")
        }

        .onChange(of: password) { _ in
            updatePasswordChecks()
            checkMainPassIsValid()
            checkIfPassesMatch()
        }
        .onChange(of: repeatPassword) { _ in
            checkMainPassIsValid()
            checkIfPassesMatch()
        }
        .padding(.horizontal, 20)
        .background(Color.theme.surface)
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .ignoresSafeArea(.all)
    }
}

#Preview {
    ChangePasswordScreen()
}

private extension ChangePasswordScreen {
    
    func checkMainPassIsValid() {
        if isCheck8Char && isCheck1lower && isCheck1Upper && isCheckSpecChar {
            mainPassIsValid = true
            debugPrint("[password: \(password), repeatPassword: \(repeatPassword)]")
            return
        }
        debugPrint("[password: \(password), repeatPassword: \(repeatPassword)]")
        mainPassIsValid = false
    }
    
    func checkIfPassesMatch() {
        if mainPassIsValid && !password.isEmpty {
            if password == repeatPassword {
                passesIsMatchAndValid = true
                debugPrint("😃 Passes is match!")
                return
            }
        }
        passesIsMatchAndValid = false
    }
func updatePasswordChecks() {
        isCheck8Char = password.count >= 8
        isCheck1lower = password.range(of: "[a-z]", options: .regularExpression) != nil
        isCheck1Upper = password.range(of: "[A-Z]", options: .regularExpression) != nil
        isCheckSpecChar = password.range(of: "[!@*$%^&*\"(),.?:{}|<>]", options: .regularExpression) != nil
    }

@ViewBuilder
    func textViewForPass(
        _ txt: Binding<String>,
        secure: Bool = false,
        placeHolder: String = "Login",
        focusField: PassFields,
        ifPassMatch: Bool = false,
        numPad: Bool = false,
        mainPass: Bool = true
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
                .focused($focusedField, equals: focusField)
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
                if mainPass {
                    if passIsTouched {
                        if ifPassMatch {
                            Image(systemName: "checkmark.circle")
                                .foregroundStyle(Color.theme.positivePrimary)
                                .padding(.horizontal, 20)
                        } else {
                            Image(systemName: "xmark.circle")
                                .foregroundStyle(Color.theme.negativePrimary)
                                .padding(.horizontal, 20)
                        }
                    }
                } else {
                    if repeatIsTouched {
                        if passesIsMatchAndValid {
                            Image(systemName: "checkmark.circle")
                                .foregroundStyle(Color.theme.positivePrimary)
                                .padding(.horizontal, 20)
                        } else {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundStyle(Color.theme.negativePrimary)
                                .padding(.horizontal, 20)
                        }
                    }
                }
            }
            
            .background(Color.theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.theme.extraLowContrast, lineWidth: 2)
            )
        }
    }
var filterBackView: some View {
        Group {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "chevron.backward")
                    .foregroundColor(Color.theme.mediumContrast)
                    .offset(y: -3)
                Text("Change Your Password")
                    .withDefaultTextModifier(font: "NexaRegular", size: 16, relativeTextStyle: .callout, color: Color.theme.mediumContrast)
            }
            .frame(maxWidth: .infinity, minHeight: 35, maxHeight: 42, alignment: .leading)
        }

    }
}
