//  Created by Timofey Privalov MobileDesk
import SwiftUI

enum MasterSwitcher: String, CaseIterable, Identifiable  {
    case reviewTab = "reviewTab"
    case notInUseTab = "notInUseTab"
    
    mutating func toggle() {
        switch self {
        case .reviewTab:
            self = .notInUseTab
        case .notInUseTab:
            self = .reviewTab
        }
    }
    var id: Self { self }
}
