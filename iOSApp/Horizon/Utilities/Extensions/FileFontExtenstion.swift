//
//  File.swift
//  Forth
//
//  Created by Timofey Privalov on 14.01.2024.
//
//
//import Foundation
//import SwiftUI
//
//
//
//extension UIFont {
//
//    static func customFont(forTextStyle textStyle: UIFont.TextStyle) -> UIFont {
//        let customFont: UIFont
//        let fontSize: CGFloat
//
//        // You will need to decide on the base font size for each text style
//        switch textStyle {
//        case .largeTitle:
//            fontSize = 34
//        case .title1:
//            fontSize = 28
//        case .title2:
//            fontSize = 22
//        case .title3:
//            fontSize = 20
//        case .headline:
//            fontSize = 17
//        case .body:
//            fontSize = 17
//        case .callout:
//            fontSize = 16
//        case .subheadline:
//            fontSize = 15
//        case .footnote:
//            fontSize = 13
//        case .caption1:
//            fontSize = 12
//        case .caption2:
//            fontSize = 11
//        // Add any additional custom cases for other styles you want to support
//        default:
//            fontSize = 17
//        }
//
//        guard let font = UIFont(name: "Nexa", size: fontSize) else {
//            fatalError("Failed to load the custom font.")
//        }
//        customFont = UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
//        return customFont
//    }
//}
//
//
////
////extension DynamicTypeSize {
////    var DynamicTypeSize: CGFloat {
////        switch self {
////        case .xSmall:
////            return 10.0
////        case .small:
////            <#code#>
////        case .medium:
////            <#code#>
////        case .large:
////            <#code#>
////        case .xLarge:
////            <#code#>
////        case .xxLarge:
////            <#code#>
////        case .xxxLarge:
////            <#code#>
////        case .accessibility1:
////            <#code#>
////        case .accessibility2:
////            <#code#>
////        case .accessibility3:
////            <#code#>
////        case .accessibility4:
////            <#code#>
////        case .accessibility5:
////            <#code#>
////        @unknown default:
////            17.0
////        }
////    }
//////    switch self {
//////    case .xSmall:
//////        return 10
//////        
//////    }
////}
// 
