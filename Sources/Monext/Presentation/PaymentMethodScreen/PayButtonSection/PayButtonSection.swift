//
//  PayButtonSection.swift
//  Monext
//
//  Created by Joshua Pierce on 12/11/2024.
//

import SwiftUI
import PassKit

struct PayButtonSection: View {
    
    let amount: String?
    
    let selectedPaymentMethod: PaymentMethod?
    let canPay: Bool
    
    let isLoading: Bool
    let onPayTapped: () -> Void
    
    @EnvironmentObject var sessionStore: SessionStateStore
    
    private var applePayPaymentMethod: PaymentMethod? {
        sessionStore.sessionState?.paymentMethodsList?.paymentMethods.first {
            if case .applePay = $0 { return true }
            return false
        }
    }
    
    var body: some View {
        
        VStack(spacing: 8) {
            
            PayButton(
                amount: amount,
                method: selectedPaymentMethod,
                canPay: canPay,
                loading: isLoading,
                onPayTapped: onPayTapped
            )
            
            if PKPaymentAuthorizationController.canMakePayments() {
                if let applePayPaymentMethod {
                    if selectedPaymentMethod == nil || sessionStore.sessionState?.paymentMethodsList?.selectablePaymentMethods.count == 1 {
                        ApplePayButton()
                    }
                }
            }
        }
        .padding(16)
        .background(sessionStore.appearance.surfaceColor)
    }
}

#Preview {
    
    VStack {
        
        Spacer()
        
        PayButtonSection(
            amount: "123,45 EUR",
            selectedPaymentMethod: PreviewData.paymentMethods.first!,
            canPay: true,
            isLoading: false
        ) {}
        
        Spacer()
        
        PayButtonSection(
            amount: "123,45 EUR",
            selectedPaymentMethod: PreviewData.paymentMethods.first!,
            canPay: true,
            isLoading: false
        ) {}
        
        Spacer()
        
        PayButtonSection(
            amount: "123,45 EUR",
            selectedPaymentMethod: nil,
            canPay: false,
            isLoading: false
        ) {}
        
        Spacer()
        
        PayButtonSection(
            amount: "123,45 EUR",
            selectedPaymentMethod: nil,
            canPay: false,
            isLoading: false
        ) {}
        
        Spacer()
        
        PayButtonSection(
            amount: "123,45 EUR",
            selectedPaymentMethod: nil,
            canPay: false,
            isLoading: false
        ) {}
        
        Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(white: 0.8))
    .environmentObject(PreviewData.sessionStore)
}
