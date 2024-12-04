//
//  PaymentMethodsListView.swift
//  Monext
//
//  Created by Joshua Pierce on 29/11/2024.
//

import SwiftUI

struct PaymentMethodsListView: View {
    
    let paymentMethods: [PaymentMethod]
    let hasWallet: Bool
    
    @Binding var selectedPaymentMethod: PaymentMethod?
    
    @EnvironmentObject var sessionStore: SessionStateStore
    @Environment(\.displayMode) var displayMode
    
    var body: some View {
        
        if paymentMethods.count == 1 || selectedPaymentMethod != nil {
            
            let paymentMethod = selectedPaymentMethod ?? paymentMethods.first!
            
            PaymentMethodItem(
                paymentMethod: paymentMethod,
                isExpanded: true,
                canNavigateBack: selectedPaymentMethod != nil && !(paymentMethods.count == 1 && !hasWallet)
            )
            .padding(.vertical, 1)
            .onTapGesture {
                
                // NOTE: should not collapse if wallet empty and only card payment methods
                if paymentMethods.count == 1 && !hasWallet { return }
                
                // NOTE: if we are collapsing back into the "payment methods list" mode,
                // we need to revert to .compact BEFORE we animate the paymentMethod selection
                if selectedPaymentMethod == paymentMethod {
                    displayMode.wrappedValue = .compact
                }
                
                withAnimation {
                    if selectedPaymentMethod == paymentMethod {
                        selectedPaymentMethod = nil
                    } else {
                        selectedPaymentMethod = paymentMethod
                    }
                }
            }
            .padding(.horizontal, 16)
            
        } else {
            
            ScrollView(.horizontal) {
                
                HStack(spacing: 10) {
                    
                    ForEach(paymentMethods, id: \.self) { paymentMethod in
                        
                        PaymentMethodItem(
                            paymentMethod: paymentMethod,
                            isExpanded: false,
                            canNavigateBack: false
                        )
                        .padding(.vertical, 1)
                        .onTapGesture {
                            withAnimation {
                                if selectedPaymentMethod == paymentMethod {
                                    selectedPaymentMethod = nil
                                } else {
                                    selectedPaymentMethod = paymentMethod
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    
    @Previewable @State var selectedPaymentMethod: PaymentMethod?
    
    VStack {
        
        Spacer()
        
        PaymentMethodsListView(
            paymentMethods: PreviewData.paymentMethods,
            hasWallet: false,
            selectedPaymentMethod: $selectedPaymentMethod
        )
        
        Spacer()
        
        PaymentMethodsListView(
            paymentMethods: PreviewData.paymentMethods,
            hasWallet: false,
            selectedPaymentMethod: .constant(PreviewData.paymentMethods.first!)
        )
        
        Spacer()
    }
    .padding()
    .background(.gray)
    .environmentObject(PreviewData.sessionStore)
}
