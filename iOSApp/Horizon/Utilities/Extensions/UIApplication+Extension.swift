//  Created by Timofey Privalov MobileDesk
import Foundation
import UIKit
import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
