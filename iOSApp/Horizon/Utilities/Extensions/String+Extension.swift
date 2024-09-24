//  Created by Timofey Privalov MobileDesk
import Foundation
extension String {
    func getDateHorizon() -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MMM-yyyy'T'HH:mm'Z'"
        let dateObj = inputFormatter.date(from: self) ?? Date()
        
        let voiceOverFormatter = DateFormatter()
        voiceOverFormatter.dateFormat = "dd/MM/yyyy"
        let voiceOverFormattedDate = voiceOverFormatter.string(from: dateObj)
        return "\(voiceOverFormattedDate)"
    }
    
    func getTimeHorizon() -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MMM-yyyy'T'HH:mm'Z'"
        let dateObj = inputFormatter.date(from: self) ?? Date()
        
        let voiceOverFormatter = DateFormatter()
        voiceOverFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let voiceOverFormattedDate = voiceOverFormatter.string(from: dateObj)
        return "\(voiceOverFormattedDate)"
    }
    
    func makeDateFrom() -> Date {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy" // "24-09-2023"
        return inputFormatter.date(from: self) ?? Date()
    }
    
}
