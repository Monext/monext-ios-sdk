//
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
    
    @State
    private var formattedText: String = ""
    
    private var isFocused: Bool {
        focusedState.wrappedValue == focusedField
    }
    
    @EnvironmentObject var sessionStore: SessionStateStore
    
    private var config: Appearance {
        sessionStore.appearance
    }
    
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
                    
                    TextField(placeholder ?? "", text: $formattedText)
                        .focused(focusedState, equals: focusedField)
                        .foregroundStyle(config.textfieldTextColor)
                        .tint(config.textfieldTextColor)
                        .keyboardType(keyboardType)
                        .textFieldStyle(MonextTextFieldStyle(config: config))
                    
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
                
                if let errorMessage {
                    Text(errorMessage)
                        .font(config.fonts.semibold12)
                        .kerning(0.4)
                        .foregroundStyle(config.errorColor)
                }
            }
        }
        // --- Synchronisation dans les deux sens ---
        .onAppear {
            // Synchronise au premier affichage (préremplissage, navigation, etc.)
            formattedText = formatter?.format(textValue) ?? textValue
        }
        .onChange(of: textValue) { newRaw in
            // Synchronise quand textValue change de l'extérieur (préremplissage, reset, etc.)
            let newFormatted = formatter?.format(newRaw) ?? newRaw
            if formattedText != newFormatted {
                formattedText = newFormatted
            }
        }
        .onChange(of: formattedText) { changedText in
            // Synchronise la valeur brute à chaque saisie utilisateur
            let rawValue = formatter?.preformattedRawValue(changedText) ?? changedText
            if textValue != rawValue {
                textValue = rawValue
            }
        }
    }
}

#Preview {
    
    let fs = FocusState()
    
    VStack {
        
        Spacer()
        
        FormFieldView<CardField>(
            label: "Card Number",
            textValue: .constant(""),
            errorMessage: nil,
            formatter: CardNumberFormatter(),
            keyboardType: .numberPad,
            focusedState: FocusState<CardField?>().projectedValue,
            focusedField: .cardNumber,
            placeholder: "0000 0000 0000 0000"
        )
        .padding()
        
        Spacer()
        
        FormFieldView<CardField>(
            label: "CVV",
            textValue: .constant(""),
            errorMessage: "An error occurred!",
            formatter: CardCvvFormatter(),
            keyboardType: .numberPad,
            focusedState: FocusState<CardField?>().projectedValue,
            focusedField: .cvv,
            placeholder: "123"
        )
        .padding()
        
        Spacer()
        
        FormFieldView<CardField>(
            label: "CVV",
            textValue: .constant(""),
            errorMessage: nil,
            formatter: CardCvvFormatter(),
            keyboardType: .numberPad,
            focusedState: FocusState<CardField?>().projectedValue,
            focusedField: .cvv,
            onTappedInfoAccessory: {}
        )
        .padding()
        
        Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(PreviewData.sessionStore.appearance.backgroundColor)
    .environmentObject(PreviewData.sessionStore)
}
