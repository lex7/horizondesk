//  Created by Timofey Privalov MobileDesk
import Foundation
import SwiftUI
import UIKit

extension View {
    
    func withDefaultTextModifier(font: String, size: CGFloat, relativeTextStyle: Font.TextStyle, color: Color) -> some View {
        modifier(TextModifier(font: font, size: size, textStyle: relativeTextStyle, color: color))
    }
    
    func withMultiTextModifier(font: String, size: CGFloat, relativeTextStyle: Font.TextStyle, color: Color, lines: Int = 1, lineSpacing: CGFloat = 8) -> some View {
        modifier(MultiLineTextModifier(font: font, size: size, textStyle: relativeTextStyle, color: color, lines: lines, lineSpacing: lineSpacing))
    }
    
    @ViewBuilder
    func makeMediumContrastView(text: String, image: String, imageFirst: Bool = true, isBold: Bool = false, color: Color = Color.theme.mediumContrast, size: Int = 16, txtStyle: Font.TextStyle = .callout) -> some View {
        Group {
            HStack {
                if !image.isEmpty {
                    switch imageFirst {
                    case true:
                        Image(systemName: image)
                            .offset(y: -2)
                        Text(text)
                    case false:
                        Text(text)
                        Image(systemName: image)
                            .offset(y: -2)
                    }
                } else {
                    Text(text)
                }
            }
            .withDefaultTextModifier(font: isBold ? "NexaBold" : "NexaRegular", size: CGFloat(size), relativeTextStyle: txtStyle, color: color)
        }
        .padding(2)
        .contentShape(Rectangle())
    }
    
    func titleView(text: String) -> some View {
        Text(text)
            .withDefaultTextModifier(font: "NexaBold", size: 15, relativeTextStyle: .subheadline, color: Color.theme.lowContrast)
    }
    func creatUniversalTypeFilterButton(text: String, typeIsAdded: Bool, colorScheme: ColorScheme, action: (()->Void)? = nil) -> some View {
        VStack(alignment: .leading) {
            Text(text)
                .withDefaultTextModifier(font: "NexaBold", size: 13, relativeTextStyle: .footnote, color: (typeIsAdded ? Color.theme.selected : Color.theme.highContrast))
                .padding(.horizontal, 14)
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(typeIsAdded ? AnyView(colorScheme == .dark ? Color.gradient.gradientLowDark : Color.gradient.gradientLowLight) : AnyView(Color.theme.surface))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(typeIsAdded ? Color.theme.muted : Color.theme.extraLowContrast, lineWidth: 1)
                )
        }
        .onTapGesture {
            action?()
        }
    }
    
    
    func topLeftHeader(title: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image("NavBarLogo2")
                .resizable()
                .scaledToFit()
                .frame(height: 56)
            Text(title)
                .font(
                    Font.custom("NexaBold", size: 18)
                )
                .foregroundColor(Color.theme.mediumContrast)
        }
        .padding(.horizontal, 16)
        
    }
    
    func topRightHeader(title: String, ifFilter: Bool = false) -> some View {
        createSysImageTitle(title: title, systemName: "slider.horizontal.3", imageFirst: false, isFilter: ifFilter)
            .padding(.horizontal, 24)
            .padding(.vertical, 6)
            .cornerRadius(40)
    }
    
    func topRightHeaderAccount(title: String = "Выход",
                               image: String = "rectangle.portrait.and.arrow.forward") -> some View {
        if #available(iOS 16, *) {
            createSysImageTitle(title: title,
                                systemName: image,
                                imageFirst: false)
                .padding(.horizontal, 24)
                .padding(.vertical, 6)
                .cornerRadius(40)
        } else {
            createSysImageTitle(title: title, systemName: "iphone.and.arrow.forward", imageFirst: false)
                .padding(.horizontal, 24)
                .padding(.vertical, 6)
                .cornerRadius(40)
        }
    }
        
    func labelWithLowContrastPadding(txt: String, bold: Bool = false, lowContrast: Bool = true, lines: Int = 1) -> some View {
        Group {
            Text(txt)
                .withMultiTextModifier(
                    font: bold ? "NexaBold" : "NexaRegular",
                    size: 12,
                    relativeTextStyle: .caption,
                    color: lowContrast ? Color.theme.mediumContrast : Color.theme.extraLowContrast,
                    lines: lines
                )
                .multilineTextAlignment(.center)
                .offset(y: 1)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(lowContrast ? Color.theme.extraLowContrast : Color.theme.mediumContrast)
                .cornerRadius(4)
        }
        
        
    }
    
    func labelWithLowContrastPaddingTime(txt: String, timeLeft: Int = 0, bold: Bool = false, lowContrast: Bool = true, lines: Int = 1) -> some View {
        Group {
            Text(txt)
                .withMultiTextModifier(
                    font: bold ? "NexaBold" : "NexaRegular",
                    size: 12,
                    relativeTextStyle: .caption,
                    color: lowContrast ? Color.theme.mediumContrast : Color.theme.extraLowContrast,
                    lines: lines
                )
                .multilineTextAlignment(.center)
                .offset(y: 1)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(lowContrast ? Color.theme.extraLowContrast : Color.theme.mediumContrast)
                .cornerRadius(4)
        }
        
    }
    
    func labelWithColoredPadding(txt: String, size: CGFloat = 12, relativeTextStyle: Font.TextStyle = .caption , color: Color = .white, bkColor: Color = Color.theme.extraLowContrast, lines: Int = 1,
                                 paddingV: CGFloat = 4) -> some View {
        Group {
            Text(txt)
                .withMultiTextModifier(
                    font: "NexaRegular",
                    size: size,
                    relativeTextStyle: relativeTextStyle,
                    color: color,
                    lines: lines
                )
                .multilineTextAlignment(.center)
                .offset(y: 1)
                .padding(.horizontal, 8)
                .padding(.vertical, paddingV)
                .background(bkColor)
                .cornerRadius(6)
        }
        
        
    }
    
    // Title: caption and String: subheadline
    @ViewBuilder
    func titleAndValue(title: String, value: String, ifPadding: Bool = true, valueColor: Color = Color.theme.highContrast, titleColor: Color = Color.theme.lowContrast, lines: Int = 1) -> some View {
        HStack() {
            VStack(alignment: .leading) {
                Text(value)
                    .withDefaultTextModifier(
                        font: "NexaRegular",
                        size: 15,
                        relativeTextStyle: .subheadline,
                        color: valueColor
                    )
                    .padding(
                        .vertical,
                        2
                    )
                Text(title)
                    .withMultiTextModifier(
                        font: "NexaRegular",
                        size: 12,
                        relativeTextStyle: .caption,
                        color: titleColor,
                        lines: lines
                    )
            }
            Spacer()
        }
        .padding(.horizontal, ifPadding ? 28 : 0)
    }
    
    @ViewBuilder
    func titleAndValueMultiLines(title: String, value: String, lines: Int = 3,
                                 valueRelativeTxtStyle: Font.TextStyle = .subheadline,
                                 valueSize: CGFloat = 15, maxWidth: CGFloat = 2) -> some View {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(value)
                        .withMultiTextModifier(
                            font: "NexaRegular",
                            size: valueSize,
                            relativeTextStyle: valueRelativeTxtStyle,
                            color: Color.theme.highContrast,
                            lines: lines
                        )
                        .padding(.vertical, 2)
                        .frame(maxWidth: UIScreen.main.bounds.width / maxWidth, alignment: .leading)
                        .lineLimit(lines)
                }
                HStack {
                    Text(title)
                        .withDefaultTextModifier(
                            font: "NexaRegular",
                            size: 12,
                            relativeTextStyle: .caption,
                            color: Color.theme.lowContrast
                        )
                    Spacer()
                }
            }
    }
    
    @ViewBuilder
    func makeNote(title: String, value: String, lines: Int = 3) -> some View {
        HStack(alignment: .top) {
            VStack {
                Text(title)
                    .withDefaultTextModifier(font: "NexaRegular", size: 12, relativeTextStyle: .caption, color: Color.theme.highContrast)
            }
            VStack {
                Text(value)
                    .withMultiTextModifier(
                        font: "NexaRegular",
                        size: 12,
                        relativeTextStyle: .caption,
                        color: Color.theme.lowContrast,
                        lines: lines
                    )
                    .frame(maxWidth: UIScreen.main.bounds.width / 1.3, alignment: .leading)
                    .lineLimit(lines)
            }
        }
    }
    
    @ViewBuilder
    func multiLines(value: String, lines: Int = 3, color: Color = Color.theme.lowContrast) -> some View {
        Text(value)
            .withMultiTextModifier(
                font: "NexaRegular",
                size: 12,
                relativeTextStyle: .caption,
                color: Color.theme.lowContrast,
                lines: lines
            )
            .lineLimit(lines)
    }
    // Date: caption and String: subheadline, with VoiceOver
    func dateTitleAndValue(
        title: String,
        value: String,
        colorValue: Color = Color.theme.highContrast,
        ifPadding: Bool = true
    ) -> some View {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "YYYY-dd-MM"
        let dateObj = inputFormatter.date(from: value) ?? Date()
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd/MM/yyyy"
        let formattedDate = outputFormatter.string(from: dateObj)
        
        let voiceOverFormatter = DateFormatter()
        voiceOverFormatter.dateFormat = "MMMM dd, yyyy"
        let voiceOverFormattedDate = voiceOverFormatter.string(from: dateObj)
        let voiceOverText = "Transaction process date is \(voiceOverFormattedDate)"
        return HStack {
            VStack(alignment: .leading) {
                Text(formattedDate)
                    .withDefaultTextModifier(font: "NexaRegular", size: 15, relativeTextStyle: .subheadline, color: colorValue)
                    .padding(.vertical, 2)
                Text(title)
                    .withDefaultTextModifier(font: "NexaRegular", size: 12, relativeTextStyle: .caption, color: Color.theme.lowContrast)
            }
            Spacer()
        }
        .padding(.horizontal, ifPadding ? 28 : 0)
        
        
    }

    // MARK: - Used on Transaction Filter screen SF Symbol + Title
    func createSysImageTitle(title: String, systemName: String, imageFirst: Bool = true, isFilter: Bool = false) -> some View {
        HStack {
            switch imageFirst {
            case true:
                Image(systemName: systemName)
                    .offset(y: -2)
                Text(title)
            case false:
                switch isFilter {
                case false:
                    Text(title)
                    Image(systemName: systemName)
                        .offset(y: -2)
                case true:
                    Text(title)
                    Image(systemName: systemName)
                        .overlay {
                            Circle()
                                .fill(Color.theme.selected)
                                .frame(width: 5, height: 5, alignment: .topTrailing)
                                .offset(x: 11, y: -9)
                        }
                }
            }
        }
        .withDefaultTextModifier(font: "NexaRegular", size: 16, relativeTextStyle: .callout,
                                 color: isFilter ? Color.theme.selected : Color.theme.mediumContrast)
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func dragIndicator() -> some View {
        ZStack(alignment: .top) {
            Capsule()
                .fill(Color.theme.extraLowContrast)
                .frame(width: 35, height: 5)
                .padding(.top, 10)
        }
    }
    func fileNameWithExtension(_ fileName: String) -> some View {
        Group {
            if let extensionRange = fileName.range(of: ".", options: .backwards), extensionRange.upperBound < fileName.endIndex {
                let name = String(fileName[..<extensionRange.lowerBound])
                let extensionPart = String(fileName[extensionRange.lowerBound...])
                HStack {
                    Text(name)
                        .withDefaultTextModifier(font: "NexaRegular", size: 17, relativeTextStyle: .headline, color: Color.theme.highContrast)
                        .lineLimit(1).truncationMode(.tail)
                    Text(extensionPart)
                        .withDefaultTextModifier(font: "NexaRegular", size: 17, relativeTextStyle: .headline, color: Color.theme.lowContrast)
                }
            } else {
                Text(fileName)
            }
        }
    }
    
    func titleHeader(
        _ title: String,
        lines: Int = 2,
        color: Color = Color.theme.highContrast,
        size: CGFloat = 17,
        relativeTextStyle: Font.TextStyle = .headline,
        uppercase: Bool = true,
        font: String = "NexaRegular") -> some View {
            Group {
                if uppercase {
                    Text(title)
                        .textCase(.uppercase)
                        .withMultiTextModifier(
                            font: font,
                            size: size,
                            relativeTextStyle: relativeTextStyle,
                            color: color,
                            lines: lines
                        )
                } else {
                    Text(title)
                        .withMultiTextModifier(
                            font: font,
                            size: size,
                            relativeTextStyle: relativeTextStyle,
                            color: color,
                            lines: lines
                        )
                }
            }
        }
}
