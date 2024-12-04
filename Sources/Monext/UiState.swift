//
//  UiState.swift
//  Monext
//
//  Created by Joshua Pierce on 29/11/2024.
//

import SwiftUI
import ThreeDS_SDK

protocol UiState {}

struct PaymentSheetUiState {
    
    struct Loading: UiState {}
    
    struct PaymentMethods: UiState {
        let token: String
        let amount: String
        let paymentMethodsList: PaymentMethodsList
    }
    
    struct Redirection: UiState {}
    
    struct Pending: UiState {}
    
    struct Success: UiState {}
    
    struct SdkChallenge: UiState {
        let challengeParameters: ChallengeParameters
    }
    
    struct Failure: UiState {}
    
    struct Cancelled: UiState {}
    
    struct TokenExpired: UiState {}
    
    struct Unknown: UiState {}
}
