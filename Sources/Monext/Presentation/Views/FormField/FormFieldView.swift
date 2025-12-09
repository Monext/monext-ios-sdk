//  FormFieldView.swift
//  Monext
//
//  Created by Joshua Pierce on 30/11/2024.
//

import SwiftUI
import UIKit

struct FormFieldView<ID: Hashable>: View {

    let label: LocalizedStringKey
    @Binding var textValue: String
    let errorMessage: LocalizedStringKey?
    let formatter: (any FormFieldView.Formatter)?
    var useOnSurfaceStyle: Bool = false
    var keyboardType: UIKeyboardType = .default
    var focusedState: FocusState<ID?>.Binding
    let focusedField: ID?
    var onTappedInfoAccessory: (() -> Void)?
    var placeholder: String? = nil

    private var isFocused: Bool {
        focusedState.wrappedValue == focusedField
    }

    @EnvironmentObject var sessionStore: SessionStateStore
    private var config: Appearance { sessionStore.appearance }

    var borderColor: Color {
        if errorMessage != nil {
            return config.errorColor
        }
        if useOnSurfaceStyle && !isFocused {
            return config.textfieldBorderOnSurfaceColor
        }
        if useOnSurfaceStyle && isFocused {
            return config.textfieldBorderSelectedOnSurfaceColor
        }
        if isFocused {
            return config.textfieldBorderSelectedColor
        }
        return config.textfieldBorderColor
    }

    var labelColor: Color {
        if errorMessage != nil {
            return config.errorColor
        }
        if useOnSurfaceStyle && !isFocused {
            return config.textfieldLabelOnSurfaceColor
        }
        if useOnSurfaceStyle && isFocused {
            return config.textfieldBorderSelectedOnSurfaceColor
        }
        if isFocused {
            return config.textfieldBorderSelectedColor
        }
        return config.textfieldLabelColor
    }

    var labelBackground: Color {
        if label.isEmpty {
            return .clear
        }
        if useOnSurfaceStyle {
            return config.surfaceColor
        }
        return config.backgroundColor
    }

    var labelUnderlay: Color {
        if useOnSurfaceStyle {
            return config.primaryAlpha
        }
        return .clear
    }

    var body: some View {
        VStack(alignment: .leading, spacing: -11) {

            Text(label)
                .font(config.fonts.semibold12)
                .kerning(0.4)
                .foregroundStyle(labelColor)
                .padding(2)
                .padding(.horizontal, 4)
                .background(labelUnderlay)
                .background(labelBackground)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .padding(.leading, 16)
                .zIndex(1)

            VStack(alignment: .leading, spacing: 0) {

                HStack {
                    // Build UIFont from AvenirNext-DemiBold for semibold20
                    let uiFont: UIFont = {
                        if let f = UIFont(name: "AvenirNext-DemiBold", size: 20) {
                            return f
                        }
                        return UIFont.preferredFont(forTextStyle: .title2)
                    }()

                    let uiTextColor = UIColor(config.textfieldTextColor)
                    let uiPlaceholderColor = UIColor(config.textfieldLabelColor).withAlphaComponent(0.6)

                    FormattingTextField<ID>(
                        rawText: $textValue,
                        formatter: formatter,
                        placeholder: placeholder ?? "",
                        keyboardType: keyboardType,
                        focusedState: focusedState,
                        focusedField: focusedField,
                        uiFont: uiFont,
                        textColor: uiTextColor,
                        placeholderColor: uiPlaceholderColor,
                        kerning: 3,
                        contentInsets: UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
                    )
                    .frame(minHeight: 52)
                    .background(Color.clear)

                    if onTappedInfoAccessory != nil {
                        Image(moduleImage: "ic.i.circle.filled")
                            .foregroundStyle(
                                useOnSurfaceStyle
                                    ? config.textfieldAccessoryOnSurfaceColor
                                    : config.textfieldAccessoryColor
                            )
                            .padding(.trailing, 12)
                            .onTapGesture {
                                onTappedInfoAccessory?()
                            }
                    }
                }
                .background(
                    useOnSurfaceStyle
                        ? config.textfieldBackgroundOnSurfaceColor
                        : config.textfieldBackgroundColor
                )
                .clipShape(RoundedRectangle(cornerRadius: config.textfieldRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: config.textfieldRadius)
                        .stroke(
                            borderColor,
                            lineWidth: isFocused ? config.textfieldStrokeSelected : config.textfieldStroke
                        )
                }

                Text(errorMessage ?? "")
                    .font(config.fonts.semibold12)
                    .kerning(0.4)
                    .foregroundStyle(config.errorColor)
                    .opacity(errorMessage == nil ? 0 : 1)
                    .frame(height: 10, alignment: .leading)
                    .padding(.top, 4)
            }
        }
    }
}
