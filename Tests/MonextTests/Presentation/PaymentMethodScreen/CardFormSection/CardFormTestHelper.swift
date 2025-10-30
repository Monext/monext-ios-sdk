//
//  CardFormTestHelper.swift
//  Monext
//
//  Created by SDK Mobile on 30/10/2025.
//

import Foundation
import SwiftUI
@testable import Monext

@MainActor
final class CardFormTestHelper {
    
    // MARK: - Factory Methods
    
    /// Crée un CardFormViewModel avec les options spécifiées
    /// - Parameter options: Liste des options à inclure (ex: "HOLDER", "CVV", etc.)
    /// - Returns: Une instance de CardFormViewModel configurée pour les tests
    static func makeCardFormViewModel(
        options: [String],
        sessionToken: String = "test",
        paymentAPI: MockPaymentAPI = MockPaymentAPI()
    ) -> CardFormViewModel {
        CardFormViewModel(
            paymentAPI: paymentAPI,
            sessionToken: sessionToken,
            paymentMethods: [
                makePaymentMethod(options: options)
            ]
        )
    }
    
    /// Crée un CardForm avec les options spécifiées
    /// - Parameter options: Liste des options à inclure
    /// - Returns: Une instance de CardForm configurée pour les tests
    static func makeCardForm(
        options: [String],
        formValid: Binding<Bool> = .constant(false)
    ) -> CardForm {
        let viewModel = makeCardFormViewModel(options: options)
        return CardForm(
            viewModel: viewModel,
            formValid: formValid
        )
    }
    
    /// Crée un PaymentMethodData avec les paramètres spécifiés
    /// - Parameters:
    ///   - options: Liste des options à inclure
    ///   - cardCode: Code de la carte (par défaut "CB")
    ///   - contractNumber: Numéro de contrat (par défaut "CB3DSV2")
    ///   - state: État de la méthode de paiement (par défaut "AVAILABLE")
    /// - Returns: Une instance de PaymentMethodData
    static func makePaymentMethod(
        options: [String],
        cardCode: String = "CB",
        contractNumber: String = "CB3DSV2",
        state: String = "AVAILABLE"
    ) -> PaymentMethodData {
        .init(
            cardCode: cardCode,
            contractNumber: contractNumber,
            disabled: false,
            hasForm: false,
            form: nil,
            hasLogo: false,
            logo: nil,
            isIsolated: false,
            options: options,
            paymentMethodAction: 0,
            additionalData: .init(),
            shouldBeInTopPosition: false,
            state: state
        )
    }
}

// MARK: - Common Test Options

extension CardFormTestHelper {
    
    /// Options communes pour les tests
    enum TestOptions {
        /// Options de base sans holder
        static let base: [String] = [
            "SAVE_PAYMENT_DATA",
            "EXPI_DATE",
            "CVV",
            "ALT_NETWORK"
        ]
        
        /// Options avec holder
        static let withHolder: [String] = base + ["HOLDER"]
        
        /// Seulement le CVV
        static let cvvOnly: [String] = ["CVV"]
        
        /// Seulement la date d'expiration
        static let expirationOnly: [String] = ["EXPI_DATE"]
        
        /// Seulement le holder
        static let holderOnly: [String] = ["HOLDER"]
        
        /// Sauvegarder la carte
        static let saveCardOnly: [String] = ["SAVE_PAYMENT_DATA"]
        
        /// Sélecteur de réseau
        static let networkPickerOnly: [String] = ["ALT_NETWORK"]
        
        /// Toutes les options
        static let all: [String] = [
            "HOLDER",
            "EXPI_DATE",
            "CVV",
            "SAVE_PAYMENT_DATA",
            "ALT_NETWORK"
        ]
        
        /// Aucune option
        static let none: [String] = []
    }
}
