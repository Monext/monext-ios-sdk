//
//  PaymentMethodsSection.swift
//  Monext
//
//  Created by Joshua Pierce on 12/11/2024.
//

import SwiftUI

struct PaymentMethodsSection: View {
    
    let paymentMethods: [PaymentMethod]
    let hasWallet: Bool
    
    @Binding var selectedPaymentMethod: PaymentMethod?

    @EnvironmentObject var sessionStore: SessionStateStore
    
    private var config: Appearance {
        sessionStore.appearance
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            if selectedPaymentMethod == nil {
                Text("Pay with")
                    .font(config.fonts.semibold14)
                    .padding(.horizontal, 16)
            }
            
            PaymentMethodsListView(
                paymentMethods: paymentMethods,
                hasWallet: hasWallet,
                selectedPaymentMethod: $selectedPaymentMethod
            )
        }
        .padding(.bottom, 16)
        .foregroundStyle(config.onHeaderBackgroundColor)
        .background(config.headerBackgroundColor)
    }
}

@available(iOS 17.0, *)
#Preview {
        
    @Previewable @State var selectedPaymentMethod: PaymentMethod?
    
    VStack {
        
        Spacer()
        
        PaymentMethodsSection(
            paymentMethods: PreviewData.paymentMethods,
            hasWallet: false,
            selectedPaymentMethod: $selectedPaymentMethod
        )
        
        Spacer()
        
        PaymentMethodsSection(
            paymentMethods: PreviewData.paymentMethods,
            hasWallet: false,
            selectedPaymentMethod: .constant(PreviewData.paymentMethods.first!)
        )
        
        Spacer()
    }
    .background(.gray)
    .environmentObject(PreviewData.sessionStore)
    .environment(\.locale, .init(identifier: "fr"))
}
