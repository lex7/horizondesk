//  Created by Timofey Privalov MobileDesk
import SwiftUI

struct ForgotPasswordScreen: View {
    
    // MARK: - Environment variables
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentationMode) private var presentationMode
    
    // MARK: - Private Constants
    private let generator = UIImpactFeedbackGenerator(style: .light)
    @State private var screenHeight = UIScreen.main.bounds.height
    
    // MARK: - Private Variables
#if DEBUG
    @State private var userId: String = "TMK-300124"
    @State private var email: String = "ivanov.amt@sinara.ru"
#else
    @State private var userId: String = ""
    @State private var email: String = ""
#endif
    @State private var selectedDob: String = ""
    @State private var selectedDate: Date
    @State private var showingDatePicker = false
    init() {
        // Initialize date as before
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        if let initialDate = dateFormatter.date(from: "13-04-1973") {
#if DEBUG
            _selectedDate = State(initialValue: initialDate)
#else
            _selectedDate = State(initialValue: Date())
#endif
        } else {
            _selectedDate = State(initialValue: Date())
        }
    }
    
    /*
     User ID field double tap to edit
     Email field double tap to edit
     Date of birth field double tap to edit
     */
    
    var body: some View {
        VStack {
            Group { 
                if false == false {
                    Group {
                        descriptionOfField("passwordRecoveryText", lines: 5, color: Color.theme.lowContrast)
                            .padding(.top, screenHeight/12)
                    } 
                    Group {
                        titleView(text: "Введите ваши данные")
                        
                            .padding(.top, screenHeight/25)
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        textView(
                            $userId,
                            placeHolder: "Табельный номер",
                            txtColor: Color.theme.mediumContrast
                        )
                        .padding(.top, screenHeight/75)
                        textView(
                            $email,
                            placeHolder: "корпоративный имэйл",
                            txtColor: Color.theme.mediumContrast
                        )
                        .padding(.top, screenHeight/100)
                        Spacer()
                    } 
                } else {
                    VStack {
                        titleView(text: "Check your inbox")
                            .padding(.top, screenHeight/12)
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        descriptionOfField("checkInbox", lines: 15, color: Color.theme.lowContrast)
                            .padding(.top, screenHeight/45)
                            .padding(.horizontal, 10)
                        
                        Spacer()
                    }
                }
            }
        }
        .overlay {
            datePicker
        }
        .overlay(
            VStack {
                HStack {
                    Text("Восстановление Пароля")
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
                            presentationMode.wrappedValue.dismiss()
                        }
                }
                .padding(.top, screenHeight/20)
                .frame(height: screenHeight * 0.03)
                .padding(.trailing, 20)
                Spacer()
                HStack {
                    Spacer()
                }
                .padding(15)
            }
        )
        .padding(.horizontal, 12)
        .background(
            colorScheme == .dark ? Color.gradient.bkGradientDarkToExtraLowContrast : Color.gradient.bkGradientLightToExtraLowContrast
        )
    }
}

#Preview {
    ForgotPasswordScreen()
}

private extension ForgotPasswordScreen {
    
    private func showNext() -> Bool {
        return !userId.isEmpty && !selectedDob.isEmpty && !email.isEmpty
    }
    @ViewBuilder
    var datePicker: some View {
        Group {
            if showingDatePicker {
                Color.black.opacity(0.01)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showingDatePicker = false
                    }
                // The modal view
                VStack {
                    DatePicker(
                        "",
                        selection: $selectedDate,
                        in: ...Date(),
                        displayedComponents: [.date]
                    )
                    //                    .datePickerStyle(WheelDatePickerStyle())
                    .datePickerStyle(.graphical)
                    .padding()
                    
                    Button(action: {
                        selectedDob = dateFormatter.string(from: selectedDate)
                        showingDatePicker = false
                    },
                           label: {
                        makeMediumContrastView(text: "Выбрать", image: "calendar.badge.checkmark", imageFirst: false)
                        
                    })
                    .padding()
                    .foregroundColor(Color.theme.surface)
                }
                .frame(width: UIScreen.main.bounds.width/1.35)
                .padding(12)
                .background(Color.theme.surface)
                .cornerRadius(12)
                .shadow(color: Color.theme.muted.opacity(0.5), radius: 9, x: 3, y: 3)
                .padding()
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}
