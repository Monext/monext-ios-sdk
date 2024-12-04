//
//  CardFormContainer.swift
//  Monext
//
//  Created by Joshua Pierce on 04/12/2024.
//

import SwiftUI

struct CardFormContainer: View {
    
    let sessionToken: String
    let paymentMethod: PaymentMethod
    
    @ObservedObject
    var viewModel: PaymentViewModel
    
    @Binding var formValid: Bool
    
    private var cardPaymentMethod: PaymentMethod? {
        if case .cards = paymentMethod {
            return paymentMethod
        }
        return nil
    }
    
    private var cardsPaymentMethodData: [PaymentMethodData] {
        if case .cards(let pms) = cardPaymentMethod {
            return pms
        }
        return []
    }
    
    @EnvironmentObject
    var sessionStore: SessionStateStore
    
    @Environment(\.displayMode)
    var displayMode
    
    var body: some View {
        ScrollView {
            
            VStack(spacing: 16) {
                
                AcceptedCardsList(paymentMethods: cardsPaymentMethodData)
                
                if let formViewModel = viewModel.cardFormViewModel {
                    CardForm(
                        viewModel: formViewModel,
                        formValid: $formValid
                    )
                }
            }
            .padding(16)
        }
        .background(sessionStore.appearance.backgroundColor)
        .transition(.move(edge: .bottom))
        .onAppear {
            displayMode.wrappedValue = .fullscreen
        }
    }
}
