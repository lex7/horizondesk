//  Created by Timofey Privalov MobileDesk
import SwiftUI
import SwiftfulRouting

struct LoginScreen: View {
    
    // MARK: - Environment variables
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var authStateEnvObject: AuthStateEnvObject
    
    // MARK: - Private Constants
    private let generator = UIImpactFeedbackGenerator(style: .light)
    
    // MARK: - Private Variables

    #if DEBUG
    @State private var username: String = "TMK-1010"
    @State private var password: String = "1234golive"
    #else
        @State private var username: String = ""
        @State private var password: String = ""
    #endif
    
    @State private var scaleLogin: Bool = false
    @State private var enableLogin: Bool = true
    
    @State private var scaleForgot: Bool = false
    @State private var enableForgot: Bool = true
    
    @State private var goToForgotPassword: Bool = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                GPToolView()
                    .padding(.top, 94)
                VStack {
                    textView($username, placeHolder: "Имэйл или Логин")
                    textView($password, secure: true, placeHolder: "Пароль")
                        .padding(.top, 12)
                    loginView
                    Spacer()
                    passwordView
                        .fullScreenCover(isPresented: $goToForgotPassword) {
                            ForgotPasswordScreen()
                        }
                } 
                .padding(.top, 120)
            } // End of VStack
            .alert("Ошибка", isPresented: $authStateEnvObject.isErrorLogin) {
                // Buttons as actions for the alert
                Button("Ok", role: .cancel) {
                    generator.impactOccurred()
                }
            } message: {
                if authStateEnvObject.isErrorCodeLogin.contains("401") {
                    Text("Не верный логин/пароль.")
                } else {
                    Text("Что-то пошло не так.")
                }
                
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(.all)
            .background(
                colorScheme == .dark ? Color.gradient.bkGradientDarkToExtraLowContrast : Color.gradient.bkGradientLightToExtraLowContrast
            )
            .onTapGesture {
                hideKeyboard()
            }
            .overlay {
                if authStateEnvObject.showProgress {
                    ProgressView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                showProgress = false
                        }
                    }
                }
            }
        } 
    }
}

// MARK: - Extension LoginScreen
private extension LoginScreen {
    @ViewBuilder
    var loginView: some View {
        makeMediumContrastView(text: "Вход", image: "arrow.forward")
            .allowsHitTesting(enableLogin)
            .scaleEffect(scaleLogin ? 0.85 : 1)
            .padding(.top, 25)
            .padding(.trailing, 20)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .onTapGesture {
                generator.prepare()
                generator.impactOccurred()
                enableLogin = false
                withAnimation(.interpolatingSpring(stiffness: 300, damping: 100)) {
                    scaleLogin = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 ) {
                    enableLogin = true
                    scaleLogin.toggle()
                }
                authStateEnvObject.username = username
                authStateEnvObject.password = password
                authStateEnvObject.userLogin()
            }
    }
    
    @ViewBuilder
    var passwordView: some View {
        makeMediumContrastView(text: "Восстановление пароля", image: "key")
            .allowsHitTesting(enableForgot)
            .scaleEffect(scaleForgot ? 0.85 : 1)
            .padding(.bottom, 55)
            .padding(.trailing, 20)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .onTapGesture {
                enableForgot = false
                withAnimation(.interpolatingSpring(stiffness: 300, damping: 100)) {
                    scaleForgot = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 ) {
                    enableForgot = true
                    scaleForgot.toggle()
                    generator.prepare()
                    generator.impactOccurred()
                }
                goToForgotPassword.toggle()
            }
    }
}
