//
//  AlternativePaymentMethodForm.swift
//  Monext
//
//  Created by SDK Mobile on 16/04/2025.
//
import SwiftUI

struct AlternativePaymentMethodForm: View {
    
    @Binding
    var saveCard: Bool
    
    var method: PaymentMethodData!
    
    @EnvironmentObject
    var sessionStore: SessionStateStore
    
    var body: some View {
        VStack {
//            Text(method.form?.description ?? "")
//                .font(sessionStore.appearance.fonts.bold16)
//                .foregroundStyle(sessionStore.appearance.onBackgroundColor)
            
            
            if let options = method.options, options.contains("SAVE_PAYMENT_DATA") {
                ToggleButton(
                    "I want to save my payment information for later.",
                    isOn: $saveCard
                )
            }
            
            
        }
        .padding()
    }
}
