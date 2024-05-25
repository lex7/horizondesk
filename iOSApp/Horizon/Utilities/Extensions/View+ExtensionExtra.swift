//  Created by Timofey Privalov MobileDesk
import Foundation
import SwiftUI

extension View {
    
    @ViewBuilder
    func descriptionOfField(_ value: String, phone: String = "", lines: Int = 3, color: Color = Color.theme.lowContrast, big: Bool = true) -> some View {
        Text(NSLocalizedString(value, comment: value) + " \(phone)")
            .withMultiTextModifier(
                font: "NexaRegular",
                size: (big ? 12 : 11),
                relativeTextStyle: (big ? .caption : .caption2),
                color: color,
                lines: lines
            )
            .lineLimit(lines)
    }
    
    @ViewBuilder
    func textView(
        _ txt: Binding<String>,
        secure: Bool = false,
        placeHolder: String = "Login",
        txtColor: Color = Color.theme.selected
    ) -> some View {
        ZStack(alignment: .leading) {
            if txt.wrappedValue.isEmpty {
                Text(placeHolder)
                    .withDefaultTextModifier(font: "NexaRegular", size: 17, relativeTextStyle: .body, color: Color.theme.secondary)
                    .padding(15)
                    .offset(y: 2)
                    .zIndex(1)
            }
            VStack {
                Group {
                    if secure {
                        SecureField("", text: txt)
                    } else {
                        TextField("", text: txt)
                    }
                }
                .accentColor(Color.theme.secondary)
                .submitLabel(.done)
                .onSubmit {
                    debugPrint("\(txt)")
                }
                .foregroundColor(txtColor)
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
    
    @ViewBuilder
    func createListPickedTypes(
        text: String,
        butPressed: Bool,
        colorScheme: ColorScheme,
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
            
            .background(butPressed ? AnyView(colorScheme == .dark ? Color.gradient.gradientLowDark : Color.gradient.gradientLowLight) : AnyView(Color.theme.surface))
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
    
    func scrollContentBackgroundHidden() -> some View {
        if #available(iOS 16.0, *) {
            return self.scrollContentBackground(.hidden)
        } else {
            return self
        }
    }
    
    func textEditorBackground<V>(@ViewBuilder _ content: () -> V) -> some View where V : View {
        self
            .onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
            .background(content())
    }
}
