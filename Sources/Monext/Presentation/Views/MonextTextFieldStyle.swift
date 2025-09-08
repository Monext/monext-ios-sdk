//
//  MonextTextFieldStyle.swift
//  Monext
//
//  Created by Joshua Pierce on 29/11/2024.
//

import SwiftUI

struct MonextTextFieldStyle: TextFieldStyle {
    
    let config: Appearance
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(config.fonts.semibold20)
            .kerning(3)
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
    }
}
