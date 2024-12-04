//
//  PaymentScreen.swift
//  Monext
//
//  Created by Joshua Pierce on 08/11/2024.
//

import SwiftUI
import WebKit
import ThreeDS_SDK

/// Result type returned to the app at the termination of a payment transaction
public enum PaymentSheetResult {
    
    /// The transaction is pending
    case paymentPending
    
    /// The transaction completed successfully
    case paymentSuccess
    
    /// The transaction failed
    case paymentFailure
    
    /// The user canceled the payment
    case paymentCanceled
    
    /// The provided token has expired
    case tokenExpired
}

struct PaymentSheet: View {
    
    let sessionToken: String
    
    @Binding var isPresented: Bool
    
    let onResult: (PaymentSheetResult) -> Void
    
    @State private var selectedPaymentMethod: PaymentMethod?
    @State private var selectedWallet: Wallet?
    @State private var overlayData: LoadingOverlayData?
    @State private var showingAlert = false
    
    @Environment(\.displayMode) private var displayMode
    @EnvironmentObject private var sessionStore: SessionStateStore
    
    var threeDSManager: ThreeDS2Manager
    @Binding var challengeExecuted: Bool
    let onChallengeRequired: ((ChallengeParameters) -> Void)?
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            
            VStack(spacing: 0) {
                
                PaymentSheetHeaderView(isPresented: $isPresented)
                
                switch uiState {
                    
                case is PaymentSheetUiState.Loading:
                    LoadingScreen()
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom),
                            removal: .opacity
                        ))
                        .onAppear {
                            displayMode.wrappedValue = .compact
                        }
                    
                case let pms as PaymentSheetUiState.PaymentMethods:
                    PaymentMethodScreen(
                        uiState: pms,
                        selectedPaymentMethod: $selectedPaymentMethod,
                        selectedWallet: $selectedWallet,
                        showingOverlay: $overlayData,
                        threeDSManager: threeDSManager,
                        paymentAPI: sessionStore.getPaymentAPI()
                    )
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        displayMode.wrappedValue = .compact
                    }
                    
                case is PaymentSheetUiState.Redirection:
                    RedirectionScreen {
                        Task {
                            try? await sessionStore.updateSessionState(token: sessionToken)
                        }
                    }
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        displayMode.wrappedValue = .fullscreen
                    }
                    
                case is PaymentSheetUiState.Pending:
                    PendingScreen() {
                        isPresented.toggle()
                    }
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        displayMode.wrappedValue = .fullscreen
                    }
                    
                case let sdkChallenge as PaymentSheetUiState.SdkChallenge:
                        LoadingScreen()
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom),
                                removal: .opacity
                            ))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .onAppear {
                                if challengeExecuted { return }
                                
                                displayMode.wrappedValue = .fullscreen
                                handleChallengeRequired(challengeParameters: sdkChallenge.challengeParameters)
                            }
                    
                case is PaymentSheetUiState.Success:
                    SuccessScreen {
                        isPresented.toggle()
                    }
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        displayMode.wrappedValue = .fullscreen
                    }
                    
                case is PaymentSheetUiState.Failure:
                    FailureScreen {
                        isPresented.toggle()
                    }
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        displayMode.wrappedValue = .fullscreen
                    }
                    
                case is PaymentSheetUiState.Cancelled:
                    CanceledScreen()
                        .transition(.move(edge: .bottom))
                        .onAppear {
                            displayMode.wrappedValue = .compact
                        }
                    
                case is PaymentSheetUiState.TokenExpired:
                    TokenExpiredScreen()
                        .transition(.move(edge: .bottom))
                        .onAppear {
                            displayMode.wrappedValue = .compact
                        }
                    
                default:
                    EmptyView()
                }
            }
            
            if case .sandbox = sessionStore.env {
                VStack {
                    Text("! TEST !\nMODE")
                        .font(sessionStore.appearance.fonts.bold14)
                        .multilineTextAlignment(.center)
                        .padding(8)
                }
                .foregroundStyle(.white)
                .background(.red)
                .clipShape(UnevenRoundedRectangle(cornerRadii: .init(bottomLeading: 16)))
            }
        }
        .overlay(loadingOverlay)
        .onChange(of: sessionStore.sessionState) { sState in
            guard let sState else { return }

            handleViewUpdatesForSessionState(sState)
            
            switch sState.type {
                case SessionType.pending.rawValue:
                    onResult(.paymentPending)
                case SessionType.success.rawValue:
                    onResult(.paymentSuccess)
                case SessionType.failure.rawValue:
                    onResult(.paymentFailure)
                case SessionType.tokenExpired.rawValue:
                    onResult(.tokenExpired)
                case SessionType.canceled.rawValue:
                    onResult(.paymentCanceled)
                default:
                    break
            }
        }
        .task {
            try? await sessionStore.updateSessionState(token: sessionToken)
        }
    }
    
    private var loadingOverlay: some View {
        if let overlayData {
            return AnyView(
                LoadingOverlay(data: overlayData)
            )
        }
        return AnyView(EmptyView())
    }
    
    // MARK: - Challenge Management
    private func handleChallengeRequired(challengeParameters: ChallengeParameters) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            onChallengeRequired?(challengeParameters)
        }
    }
}

extension PaymentSheet {
    
    private var sessionState: SessionState? {
        sessionStore.sessionState
    }
    
    package var uiState: any UiState {
        
        switch sessionState?.type {
            
        case SessionType.paymentMethods.rawValue:
            guard let token = sessionState?.token else { return PaymentSheetUiState.Loading() }
            guard let amount = sessionState?.info?.formattedAmount else { return PaymentSheetUiState.Loading() }
            guard let listObj = sessionState?.paymentMethodsList else { return PaymentSheetUiState.Loading() }
            return PaymentSheetUiState.PaymentMethods(
                token: token,
                amount: amount,
                paymentMethodsList: listObj
            )
            
        case SessionType.redirection.rawValue:
            return PaymentSheetUiState.Redirection()
            
        case SessionType.pending.rawValue:
            return PaymentSheetUiState.Pending()
            
        case SessionType.success.rawValue:
            return PaymentSheetUiState.Success()
            
        case SessionType.sdkChallenge.rawValue:
            guard let sdkChallengeData = sessionState?.paymentSdkChallenge?.sdkChallengeData else { return PaymentSheetUiState.Loading() }
            return PaymentSheetUiState.SdkChallenge(
                challengeParameters: sdkChallengeData.toChallengeParameters()
            )
            
        case SessionType.failure.rawValue:
            return PaymentSheetUiState.Failure()
            
        case SessionType.canceled.rawValue:
            return PaymentSheetUiState.Cancelled()
            
        case SessionType.tokenExpired.rawValue:
            return PaymentSheetUiState.TokenExpired()
            
        default:
            return PaymentSheetUiState.Loading()
        }
    }
    
    /// NOTE: Auto-select payment method if only one (selectable)
    private func handleViewUpdatesForSessionState(_ sessionState: SessionState) {
        guard let listObj = sessionState.paymentMethodsList else { return }
        let paymentMethods = listObj.selectablePaymentMethods
        let hasMultiplePaymentMethods = paymentMethods.count > 1
        let singlePaymentMethod = paymentMethods.first
        if listObj.wallets.isEmpty, !hasMultiplePaymentMethods, let singlePaymentMethod {
            selectedPaymentMethod = singlePaymentMethod
        }
    }
}
