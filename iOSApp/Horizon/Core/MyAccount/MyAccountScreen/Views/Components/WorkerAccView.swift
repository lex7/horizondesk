
//
//  Created by Timofey Privalov MobileDesk
import SwiftUI

struct WorkerAccView: View {
    
    @Binding var DeskAccountNumber: String
    @Binding var dateCreated: String

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(DeskAccountNumber)
                        .withMultiTextModifier(font: "NexaRegular", size: 15, relativeTextStyle: .subheadline, color: Color.theme.highContrast, lines: 2)
                    Text("Логин работника")
                        .withMultiTextModifier(font: "NexaRegular", size: 12, relativeTextStyle: .caption, color: Color.theme.lowContrast, lines: 2)
                        .padding(.top, 4)
                        
                }
                Spacer()
                HStack(alignment: .top) {
                    labelWithLowContrastPadding(txt: "Стаж с " + makeDate(dateCreated), lines: 2)
                        .offset(y: -10)
                }
            }
        }
    }
}

private extension WorkerAccView {
    func makeDate(_ value: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        let dateObj = inputFormatter.date(from: value) ?? Date()
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd/MM/yyyy"
        let formattedDate = outputFormatter.string(from: dateObj)
        return formattedDate
    }
    
    func voiceDate(_ value: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        let dateObj = inputFormatter.date(from: value) ?? Date()
        
        let voiceOverFormatter = DateFormatter()
        voiceOverFormatter.dateFormat = "MMMM dd, yyyy"
        let voiceOverFormattedDate = voiceOverFormatter.string(from: dateObj)
        return "\(voiceOverFormattedDate)"
    }
}
