//
//  SecurityPaymentSheetPresenter.swift
//  Monext
//
//  Created by lucas bianciotto  on 29/09/2026.
//

import SwiftUI

struct SecurityPaymentSheetPresenter: ViewModifier {

    @Binding var isPresented: Bool
    let sessionToken: String
    let sessionStateStore: SessionStateStore
    let detector: CompromisedDeviceDetecting
    let onResult: (PaymentSheetResult) -> Void

    @State var showSecurityAlert = false

    func body(content: Content) -> some View {
        content
            .modifier(
                PaymentSheetPresenter(
                    isPresented: securedPresentation,
                    sessionToken: sessionToken,
                    sessionStateStore: sessionStateStore,
                    onResult: onResult
                )
            )
            // Intercepte l'ouverture de la PaymentSheet
            .onChange(of: isPresented) { newValue in
                handlePresentationChange(newValue)
            }
            // Alerte de sécurité — utilise les localisations du module
            .alert(
                Text("Unsecured device", comment: ""),
                isPresented: $showSecurityAlert
            ) {
                Button(role: .cancel) {
                    showSecurityAlert = false
                } label: {
                    Text("Close", comment: "")
                }
            } message: {
                Text("Your device does not meet the security requirements to process a payment.", comment: "")
            }
    }

    // La sheet ne s'ouvre jamais sur un device compromis, même avant que onChange ne remette isPresented à false
    var securedPresentation: Binding<Bool> {
        Binding(
            get: { isPresented && !detector.isCompromised() },
            set: { isPresented = $0 }
        )
    }

    func handlePresentationChange(_ newValue: Bool) {
        guard newValue, detector.isCompromised() else { return }
        // Annule l'ouverture et affiche l'alerte de sécurité
        isPresented = false
        showSecurityAlert = true
    }
}
