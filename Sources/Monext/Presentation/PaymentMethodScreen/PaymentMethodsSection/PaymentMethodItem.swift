//
//  PaymentMethodItem.swift
//  Monext
//
//  Created by Joshua Pierce on 29/11/2024.
//

import SwiftUI

struct PaymentMethodItem: View {
    
    let paymentMethod: PaymentMethod
    let isExpanded: Bool
    let canNavigateBack: Bool
    
    @EnvironmentObject
    var sessionStore: SessionStateStore
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            
            ImageResolver.imageChipForPaymentMethod(paymentMethod, expanded: isExpanded)
                .overlay(
                    RoundedRectangle(cornerRadius: sessionStore.appearance.paymentMethodRadius)
                        .stroke(
                            sessionStore.appearance.onHeaderBackgroundAlpha,
                            lineWidth: 1
                        )
                )
            
            if isExpanded, canNavigateBack {
                Image(moduleImage: "ic.arrow.left")
                    .foregroundStyle(.black)
                    .padding(.leading, 6)
            }
        }
    }
}

#Preview {
    
    let config = PreviewData.paymentSheetConfig
    
    VStack {
        
        Spacer()
        
        PaymentMethodItem(
            paymentMethod: PreviewData.paymentMethods[2],
            isExpanded: true,
            canNavigateBack: false
        )
        
        Spacer()
        
        PaymentMethodItem(
            paymentMethod: PaymentMethod.cards(PaymentMethodData.cardGroup),
            isExpanded: false,
            canNavigateBack: false
        )
        
        Spacer()
        
        PaymentMethodItem(
            paymentMethod: PaymentMethod.cards(PaymentMethodData.cardGroup),
            isExpanded: true,
            canNavigateBack: true
        )
        
        Spacer()
    }
    .padding()
    .background(config.headerBackgroundColor)
    .environmentObject(PreviewData.sessionStore)
}
