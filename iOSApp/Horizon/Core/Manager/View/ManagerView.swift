//
//  ManagerView.swift
//  DeskHorizon
//
//  Created by Timofey Privalov on 23.09.2024.
//

import SwiftUI
import Charts
import GameplayKit

private enum textFieldFocus: Hashable {
    case statusType
    case area
}

struct ManagerView: View {
    
    // MARK: - Environment variables
    @EnvironmentObject private var authStateEnvObject: AuthStateEnvObject
    @Environment(\.colorScheme) private var colorScheme
    @State private var screenWidth = UIScreen.main.bounds.width
    @State private var screenHeight = UIScreen.main.bounds.height
    
    // MARK: - Private State Variables
    @State private var selectedSegment: MyAccountSwitcher = .information
    private let generator = UIImpactFeedbackGenerator(style: .light)
    
    // MARK: Date from
    @State private var dateFrom = Date.now
    @State private var showingDatePickerFrom: Bool = false
    @State private var selectedDateFromDate: Date = Date()
    @State private var selectedDateFrom: String?
    
    // MARK: - Date To /// selectedDateFrom
    @State private var showingDatePickerTo: Bool = false
    @State private var selectedDateToDate: Date = Date()
    @State private var selectedDateTo: String?
    
    // Area and Specialization titles
    @State private var titleOfIssue: String = ""
    @State private var areaOfIssueNumber: String = ""
    @State private var statusOfIssue: String = ""
    
    // Filter
    @State private var filterIsVisible: Bool = false
    
    /// Filter Fields
    @State private var specializationTypeFilter: Int?
    @State private var areaIdFilter: Int?
    @State private var statusFilter: String?
    
    // Picker
    @State private var managerSegment: ManagerSwitcher = .allStats
    
    // Sorting
    @State private var sortUpName: Bool = false
    @State private var sortUpRate: Bool = false
    @State private var sortUpSpec: Bool = false
    
    // FOCUS
    @FocusState private var focusedField: textFieldFocus?
    
    var scrollPositionEnd: Date {
        authStateEnvObject.scrollPositionStart.addingTimeInterval(3600 * 24 * 30)
    }
    
//    var scrollPositionString: String {
//        authStateEnvObject.scrollPositionStart.formatted(.dateTime.month().day())
//    }
    
    var scrollPositionString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMM" // Example: "31 декабря", adjust format as needed
        return formatter.string(from: authStateEnvObject.scrollPositionStart)
    }
    
    var scrollPositionEndString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMM" // Example: "31 декабря", adjust format as needed
        return formatter.string(from: scrollPositionEnd)
    }
    
    // MARK: - Binding
    @Binding var tabSelection: TabBarItem
    
    var body: some View {
        VStack {
            HStack {
                topLeftHeader(title: "Статистика")
                Spacer()
                topRightHeaderAccount()
                    .onTapGesture {
                        generator.impactOccurred()
                        authStateEnvObject.usersRating = []
                        authStateEnvObject.allStatsFragments = []
                        authStateEnvObject.logout {
                            authStateEnvObject.clearToken()
                            if authStateEnvObject.authState == .authorized {
                                authStateEnvObject.tabBarSelection = .createIssue
                                authStateEnvObject.authState = .unauthorized
                            }
                        }
                    }
            }
            .offset(y: -5)
            pickerContainer
                .padding(.horizontal, 10)
            switch managerSegment {
            case .allStats:
                ScrollView(showsIndicators: false) {
                    VStack {
                        Text("\(scrollPositionString) – \(scrollPositionEndString)")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .padding(.top, 20)
                        if authStateEnvObject.statsIsLoading {
                            ProgressView()
                                .frame(height: 190)
                        } else {
                            DailySalesChart(scrollPosition: $authStateEnvObject.scrollPositionStart,
                                            dataForChart: $authStateEnvObject.allStatsFragments,
                                            visibleDomain: .constant(30))
                                .frame(height: 190)
                        }
                        HStack {
                            if let selectedDateFrom = selectedDateFrom {
                                createListPickedTypes(text: selectedDateFrom.isEmpty ? "дата от" : selectedDateFrom,
                                                      butPressed: selectedDateFrom.isEmpty,
                                                      size: 17,
                                                      fontSize: .body) {
                                    showingDatePickerFrom = true
                                }
                            } else {
                                createListPickedTypes(text: "дата от",
                                                      butPressed: false,
                                                      size: 17,
                                                      fontSize: .body) {
                                    showingDatePickerFrom = true
                                }
                            }
                            if let selectedDateTo = selectedDateTo {
                                createListPickedTypes(text: selectedDateTo.isEmpty ? "дата до" : selectedDateTo,
                                                      butPressed: selectedDateTo.isEmpty,
                                                      size: 17,
                                                      fontSize: .body) {
                                    showingDatePickerTo = true
                                }
                            } else {
                                createListPickedTypes(text: "дата до",
                                                      butPressed: false,
                                                      size: 17,
                                                      fontSize: .body) {
                                    showingDatePickerTo = true
                                }
                            }
                        }
                        .padding(.top, 10)
                        menuIssueTheme
                            .padding(.top, 10)
                        areaIssue
                            .padding(.top, 10)
                        statusIssue
                            .padding(.top, 10)
                        HStack {
                            Spacer()
                            makeMediumContrastView(text: "Отфильтровать", image: "paperplane", imageFirst: false)
                                .padding(.top, 20)
                                .onTapGesture {
                                    generator.impactOccurred()
                                    let model = BossFilterModel(from_date: selectedDateFrom,
                                                                until_date: selectedDateTo,
                                                                status: statusFilter,
                                                                request_type: specializationTypeFilter,
                                                                area_id: areaIdFilter)
                                    authStateEnvObject.filterRequests(model)
                                }
                        }
                    } /// End of VStack Scroll
                    .padding(.horizontal, 20)
                } /// End of ScrollView
            case .filteredStats:
                HStack {
                    Spacer()
                    sortingRating
//                    filterBottom
                }
                VStack {
                    ScrollView(showsIndicators: false) {
                        ForEach(authStateEnvObject.usersRating, id: \.self) { user in
                            makeRatingCell(user)
                        }
                    }
                    .padding(.top, 10)
                }
            }
            Spacer()
        } /// End of VStack
        .alert("Уведомление", isPresented: $authStateEnvObject.showAlertOfFilter) {
            // Buttons as actions for the alert
            Button("Ok", role: .cancel) {
                generator.impactOccurred()
            }
        } message: {
            Text("Нет заявок, соответствующих указанным фильтрам!")
        }
        .fullScreenCover(isPresented: $authStateEnvObject.isPresentFiltered, onDismiss: {
            authStateEnvObject.filteredChartFragments = []
            authStateEnvObject.getAllStats()
        }, content: {
            FilteredDetailsView(currentChart: $authStateEnvObject.filteredChartFragments,
                                scrollPosition: $authStateEnvObject.filtereScrollPositionStart,
                                visibleDomain: $authStateEnvObject.visibleDomain,
                                issues: $authStateEnvObject.issuesFilteredBoss)
        })
        .overlay {
            datePickerFrom
        }
        .overlay {
            datePickerTo
        }
        .overlay {
            if authStateEnvObject.filteredIsLoading {
                ProgressView()
            }
        }
        .onAppear {
            Task {
                authStateEnvObject.getAllStats()
                try await Task.sleep(nanoseconds: 200_000_000)
                authStateEnvObject.getRating()
            }
        }
    }
}

private extension ManagerView {
    @ViewBuilder
    func createListPickedTypes(
        text: String,
        butPressed: Bool,
        size: CGFloat = 13,
        fontSize: Font.TextStyle = .footnote,
        action: @escaping ()->Void
    ) -> some View {
        HStack {
            HStack {
                Text(text)
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
            }
            .withDefaultTextModifier(font: "NexaRegular", size: size, relativeTextStyle: fontSize, color: Color.theme.selected)
            .padding(.horizontal, 16)
            .padding(.vertical, 22)
            .frame(maxWidth: .infinity)
            
            .background(Color.theme.surface)
            .cornerRadius(10)
            
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(butPressed ? Color.theme.muted : Color.theme.extraLowContrast, lineWidth: 2)
        )
        .onTapGesture {
            action()
        }
    }
    
    /// Date Picker
    @ViewBuilder
    var datePickerFrom: some View {
        Group {
            if showingDatePickerFrom {
                Color.black.opacity(0.01)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showingDatePickerFrom = false
                    }
                // The modal view
                // Calendar.current.date(byAdding: .year, value: -1, to: Date())
                VStack {
                    DatePicker(
                        "Select Date",
                        selection: $selectedDateFromDate,
                        in: Date().addingTimeInterval(-3650*24*60*60)...Date(),
                        displayedComponents: [.date]
                    )
                    .environment(\.locale, Locale.init(identifier: "Ru_ru"))
                    .onChange(of: selectedDateFromDate) { _ in
                        updateSelectedTimeFrom()
                    }
                    .datePickerStyle(WheelDatePickerStyle())
                    .padding()
                    Button(action: {
                        selectedDateFrom = dateFormatter.string(from: selectedDateFromDate)
                        showingDatePickerFrom = false
                    },
                           label: {
                        makeMediumContrastView(text: "Выбрать", image: "calendar.badge.checkmark", imageFirst: false)
                    })
                    .padding()
                    .foregroundColor(Color.theme.surface)
                }
                .frame(maxWidth: screenWidth/1.5, alignment: .center)
                .padding(12)
                .background(Color.theme.surface)
                .cornerRadius(12)
                .shadow(color: Color.theme.muted.opacity(0.5), radius: 9, x: 3, y: 3)
                .padding()
            }
        }
    }
    
    private func updateSelectedTimeFrom() {
        let today = Calendar.current.startOfDay(for: Date())
        if Calendar.current.isDate(selectedDateFromDate, inSameDayAs: today) {
            selectedDateFrom = dateFormatter.string(from: selectedDateFromDate)
        } else {
            selectedDateFrom = dateFormatter.string(from: selectedDateFromDate)
        }
    }
    
    @ViewBuilder
    var datePickerTo: some View {
        Group {
            if showingDatePickerTo {
                Color.black.opacity(0.01)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showingDatePickerTo = false
                    }
                // The modal view
                VStack {
                    DatePicker(
                        "",
                        selection: $selectedDateToDate,
                        in: Date().addingTimeInterval(-365*24*60*60)...Date(),
                        displayedComponents: [.date]
                    )
                    .environment(\.locale, Locale.init(identifier: "Ru_ru"))
                    .onChange(of: selectedDateToDate) { _ in
                        updateSelectedTimeTo()
                    }
                    .datePickerStyle(WheelDatePickerStyle())
                    //                    .padding()
                    Button(action: {
                        selectedDateTo = dateFormatter.string(from: selectedDateToDate)
                        showingDatePickerTo = false
                    },
                           label: {
                        makeMediumContrastView(text: "Выбрать", image: "calendar.badge.checkmark", imageFirst: false)
                    })
                    .padding()
                    .foregroundColor(Color.theme.surface)
                }
                .frame(maxWidth: screenWidth/1.5, alignment: .center)
                .padding(12)
                .background(Color.theme.surface)
                .cornerRadius(12)
                .shadow(color: Color.theme.muted.opacity(0.5), radius: 9, x: 3, y: 3)
                .padding()
            }
        }
    }
    
    private func updateSelectedTimeTo() {
        let today = Calendar.current.startOfDay(for: Date())
        if Calendar.current.isDate(selectedDateFromDate, inSameDayAs: today) {
            selectedDateTo = dateFormatter.string(from: selectedDateToDate)
            //            selectedTime = Date().addingTimeInterval(2 * 60 * 60)
            //            selectedMeetingTime = dateTimeFormatter.string(from: selectedTime)
        } else {
            selectedDateTo = dateFormatter.string(from: selectedDateToDate)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_us")
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }
    
    // MARK: - Specialization and Area
    
    /// Specialization
    @ViewBuilder
    func textViewOnBoard(
        _ txt: Binding<String>,
        placeHolder: String = "Cпециализация",
        focusField: textFieldFocus
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
                    TextField("", text: txt)
                }
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
    
    var menuIssueTheme: some View {
        HStack {
            // Wrapping Text inside Menu to show options on tap
            Menu {
                Button(RequestTypeEnum.electricity.name) {
                    specializationTypeFilter = RequestTypeEnum.electricity.rawValue
                    titleOfIssue = RequestTypeEnum.electricity.name
                }
                Button(RequestTypeEnum.tools.name) {
                    specializationTypeFilter = RequestTypeEnum.tools.rawValue
                    titleOfIssue = RequestTypeEnum.tools.name
                }
                Button(RequestTypeEnum.docs.name) {
                    specializationTypeFilter = RequestTypeEnum.docs.rawValue
                    titleOfIssue = RequestTypeEnum.docs.name
                }
                Button(RequestTypeEnum.sanpin.name) {
                    specializationTypeFilter = RequestTypeEnum.sanpin.rawValue
                    titleOfIssue = RequestTypeEnum.sanpin.name
                }
                Button(RequestTypeEnum.safety.name) {
                    specializationTypeFilter = RequestTypeEnum.safety.rawValue
                    titleOfIssue = RequestTypeEnum.safety.name
                }
                Button(RequestTypeEnum.empty.name) {
                    specializationTypeFilter = nil
                    titleOfIssue = RequestTypeEnum.empty.name
                }
            } label: {
                textViewOnBoard($titleOfIssue, focusField: .area)
            }
            Spacer()
        }
    }
    
    /// Area
    var areaIssue: some View {
        HStack {
            // Wrapping Text inside Menu to show options on tap
            Menu {
                Button(RegionIssue.areaOne.name) {
                    areaIdFilter = RegionIssue.areaOne.rawValue
                    areaOfIssueNumber = RegionIssue.areaOne.name
                }
                Button(RegionIssue.areaTwo.name) {
                    areaIdFilter = RegionIssue.areaTwo.rawValue
                    areaOfIssueNumber = RegionIssue.areaTwo.name
                }
                Button(RegionIssue.areaThree.name) {
                    areaIdFilter = RegionIssue.areaThree.rawValue
                    areaOfIssueNumber = RegionIssue.areaThree.name
                }
                Button(RegionIssue.areaFour.name) {
                    areaIdFilter = RegionIssue.areaFour.rawValue
                    areaOfIssueNumber = RegionIssue.areaFour.name
                }
                Button(RegionIssue.empty.name) {
                    areaIdFilter = nil
                    areaOfIssueNumber = RegionIssue.empty.name
                }
            } label: {
                textViewOnBoard($areaOfIssueNumber, placeHolder: "Выберите участок", focusField: .area)
            }
            Spacer()
        }
    }
    
    /// Status
    var statusIssue: some View {
        HStack {
            // Wrapping Text inside Menu to show options on tap
            Menu {
                Button(StatusIssue.done.name) {
                    statusFilter = StatusIssue.done.rawValue
                    statusOfIssue = StatusIssue.done.name
                }
                Button(StatusIssue.inProgress.name) {
                    statusFilter = StatusIssue.inProgress.rawValue
                    statusOfIssue = StatusIssue.inProgress.name
                }
                Button(StatusIssue.denied.name) {
                    statusFilter = StatusIssue.denied.rawValue
                    statusOfIssue = StatusIssue.denied.name
                }
                Button("") {
                    statusFilter = nil
                    statusOfIssue = "Выберите Статус"
                }
            } label: {
                textViewOnBoard($statusOfIssue, placeHolder: "Выберите Статус", focusField: .statusType)
            }
            Spacer()
        }
    }
    
    // Sorting
    var sortingRating: some View {
        HStack {
            Spacer()
            // Wrapping Text inside Menu to show options on tap
            Menu {
                Button("По рэйтингу") {
                    generator.impactOccurred()
                    authStateEnvObject.makeSortingRating(sortUpRate)
                    sortUpSpec = false
                    sortUpName = false
                    sortUpRate.toggle()
                }
                Button("По фамилии") {
                    generator.impactOccurred()
                    authStateEnvObject.makeSortingName(sortUpName)
                    sortUpRate = false
                    sortUpSpec = false
                    sortUpName.toggle()
                }
                Button("По должности") {
                    generator.impactOccurred()
                    authStateEnvObject.makeSortingSpec(sortUpSpec)
                    sortUpRate = false
                    sortUpName = false
                    sortUpSpec.toggle()
                }
            } label: {
                filterBottom
//                textViewOnBoard($statusOfIssue, placeHolder: "Выберите Статус", focusField: .statusType)
            }
        }
    }
    
    // Picker
    var pickerContainer: some View {
        HStack(alignment: .center, spacing: 4) {
            ManagerLeftSegmentView(sectionSelected: $managerSegment, label: "Все заявки")
                .onTapGesture {
                    generator.prepare()
                    generator.impactOccurred()
                    managerSegment.toggle()
                }
                .allowsHitTesting(managerSegment != .allStats)
            ManagerRightSegmentView(sectionSelected: $managerSegment, label: "Рейтинг")
                .onTapGesture {
                    generator.prepare()
                    generator.impactOccurred()
                    managerSegment.toggle()
                }
                .allowsHitTesting(managerSegment != .filteredStats)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .inset(by: 0.5)
                .stroke(Color.theme.extraLowContrast, lineWidth: 1)
        )
        .background(Color.theme.surface)
        .cornerRadius(28)
    }
    
    /// USER RATING
    
    func makeRatingCell(_ user: UserRatingModel) -> some View {
        VStack {
            HStack {
                descriptionOfField("ФИО:", color: sortUpName ? Color.theme.primary : Color.theme.secondary)
                Spacer()
                descriptionOfField("\(user.surname) \(user.name) \(user.middle_name)")
            }
            HStack {
                if let spec = user.specialization {
                    descriptionOfField("Должность:", color: sortUpSpec ? Color.theme.primary : Color.theme.secondary)
                    Spacer()
                    descriptionOfField(spec)
                }
            }
            HStack {
                descriptionOfField("Заявок создано:", color: Color.theme.secondary)
                Spacer()
                descriptionOfField("\(user.num_created)")
            }
            HStack {
                descriptionOfField("Заявок выполнено:", color: Color.theme.secondary)
                Spacer()
                descriptionOfField("\(user.num_completed)")
            }
            HStack {
                descriptionOfField("Токены:", color: sortUpRate ? Color.theme.primary : Color.theme.secondary)
                Spacer()
                descriptionOfField("\(user.tokens)")
            }
            
        } /// End of VStack cell
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    var filterBottom: some View {
        createSysImageTitle(title: "Сортировка", systemName: "line.3.horizontal.decrease.circle", imageFirst: false)
            .padding(.horizontal, 24)
            .padding(.top, 10)
            .cornerRadius(40)
    }
}

/*
 user_id: Int
 surname: String
 name: String
 middle_name: String
 tokens: Int
 num_created: Int
 num_completed: Int
 */
