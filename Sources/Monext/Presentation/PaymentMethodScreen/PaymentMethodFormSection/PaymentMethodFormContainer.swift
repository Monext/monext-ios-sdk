//
//  PaymentMethodFormContainer.swift
//  Monext
//
//  Created by Joshua Pierce on 04/12/2024.
//

import SwiftUI

struct PaymentMethodFormContainer: View {
    
    let paymentMethod: PaymentMethod
    
    @ObservedObject var viewModel: PaymentViewModel
    
    @EnvironmentObject
    var sessionStore: SessionStateStore
    
    var body: some View {
        ZStack {
            if paymentMethod.data?.hasForm == true {
                AlternativePaymentMethodForm(
                    saveCard: $viewModel.saveCard,
                    formValid: $viewModel.formValid,
                    formData: $viewModel.alternativeFormData,
                    method: paymentMethod.data
                )

            } else {
                EmptyView()
            }
        }
        .background(sessionStore.appearance.backgroundColor)
    }
}

struct NotImplementedFormView: View {
    var body: some View {
        Text("Payment Method not implemented")
            .padding()
    }
}
