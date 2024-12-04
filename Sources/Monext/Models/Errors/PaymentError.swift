//
//  PaymentError.swift
//  Monext
//
//  Created by SDK Mobile on 06/08/2025.
//

import Foundation


enum PaymentError: Error, LocalizedError {
    case threeDSNotInitialized
    case invalidPaymentParameters
    case sessionTokenMissing
    case paymentProcessingFailed(String)
    case networkError(Error)
    case invalidCardInfo
    case walletCvvMissing
    case walletNotSelected
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .threeDSNotInitialized:
            return "Le système 3D Secure n'est pas initialisé"
        case .invalidPaymentParameters:
            return "Les paramètres de paiement sont invalides"
        case .sessionTokenMissing:
            return "Le token de session est manquant"
        case .paymentProcessingFailed(let reason):
            return "Échec du traitement du paiement: \(reason)"
        case .networkError(let error):
            return "Erreur réseau: \(error.localizedDescription)"
        case .invalidCardInfo:
            return "Les informations de carte sont invalides"
        case .walletCvvMissing:
            return "Le CVV du portefeuille est requis"
        case .walletNotSelected:
            return "Aucun portefeuille sélectionné"
        case .unknownError:
            return "Une erreur inconnue s'est produite"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .threeDSNotInitialized:
            return "Le service 3D Secure doit être initialisé avant d'effectuer un paiement"
        case .invalidPaymentParameters:
            return "Vérifiez que tous les paramètres de paiement sont correctement renseignés"
        case .sessionTokenMissing:
            return "Une session valide est requise pour effectuer un paiement"
        case .paymentProcessingFailed:
            return "Le serveur de paiement a rejeté la transaction"
        case .networkError:
            return "Vérifiez votre connexion internet"
        case .invalidCardInfo:
            return "Vérifiez les informations de votre carte"
        case .walletCvvMissing:
            return "Saisissez le CVV de votre carte"
        case .walletNotSelected:
            return "Sélectionnez un portefeuille pour continuer"
        case .unknownError:
            return "Contactez le support technique"
        }
    }
}
