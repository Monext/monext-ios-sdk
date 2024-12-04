//
//  ToggleButton.swift
//  Monext
//
//  Created by Joshua Pierce on 28/11/2024.
//

import SwiftUI

struct ToggleButton: View {
    
    @Binding
    var isOn: Bool
    
    let labelText: LocalizedStringKey
    
    @EnvironmentObject
    var sessionStore: SessionStateStore
    
    private var config: Appearance {
        sessionStore.appearance
    }
    
    init(_ labelText: LocalizedStringKey, isOn: Binding<Bool>) {
        self.labelText = labelText
        self._isOn = isOn
    }
    
    var body: some View {
        
        HStack {
            
            Text(labelText)
                .font(config.fonts.semibold14)
            
            Spacer()
            
            Group {
                if isOn {
                    ZStack {
                        Image(moduleImage: "ic.checkbox.selected")
                        Image(moduleImage: "ic.checkbox.check")
                            .foregroundStyle(config.onSecondaryColor)
                    }
                } else {
                    Image(moduleImage: "ic.checkbox.unselected")
                }
            }
            .foregroundStyle(config.secondaryColor)
        }
        .foregroundStyle(config.onBackgroundColor)
        .onTapGesture {
            isOn.toggle()
        }
    }
}

#Preview {
    
    let config = PreviewData.paymentSheetConfig
    
    VStack {
        Spacer()
        ToggleButton("ToggleButtonView label", isOn: .constant(true))
        Spacer()
        ToggleButton("ToggleButtonView label", isOn: .constant(false))
        Spacer()
    }
    .background(config.backgroundColor)
    .environmentObject(PreviewData.sessionStore)
}
