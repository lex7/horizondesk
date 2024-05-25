//  Created by Timofey Privalov MobileDesk
import Foundation
import SwiftUI


struct TextModifier: ViewModifier {
    
    let font: String
    let size: CGFloat
    let textStyle: Font.TextStyle
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .font(Font.custom(font, size: size, relativeTo: textStyle))
            .lineLimit(/*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
            .foregroundColor(color)
    }
}


struct MultiLineTextModifier: ViewModifier {
    
    let font: String
    let size: CGFloat
    let textStyle: Font.TextStyle
    let color: Color
    let lines: Int
    let lineSpacing: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(Font.custom(font, size: size, relativeTo: textStyle))
            .lineLimit(lines)
            .foregroundColor(color)
            .lineSpacing(lineSpacing)
    }
}
