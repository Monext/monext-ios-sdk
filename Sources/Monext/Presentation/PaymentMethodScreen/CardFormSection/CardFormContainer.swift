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
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {

                    AcceptedCardsList(paymentMethods: cardsPaymentMethodData)
                    
                    if let formViewModel = viewModel.cardFormViewModel {
                        CardForm(
                            viewModel: formViewModel,
                            formValid: $formValid,
                            onFieldFocused: { field in
                                if let field = field {
                                    // Scroll avec un léger délai pour laisser le clavier apparaître
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                        withAnimation(.easeInOut(duration: 0.05)) {
                                            // Utiliser UnitPoint pour positionner exactement en haut
                                            proxy.scrollTo(field, anchor: UnitPoint(x: 0, y: 0))
                                        }
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(16)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(sessionStore.appearance.backgroundColor)
        .transition(.move(edge: .bottom))
        .onAppear {
            displayMode.wrappedValue = .fullscreen
        }
    }
}
