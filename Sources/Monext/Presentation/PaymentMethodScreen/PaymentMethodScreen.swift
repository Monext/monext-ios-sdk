//
//  PaymentScreen.swift
//  Monext
//
//  Created by Joshua Pierce on 29/11/2024.
//

import SwiftUI

struct PaymentMethodScreen: View {
    
    let uiState: PaymentSheetUiState.PaymentMethods
    
    @Binding var selectedPaymentMethod: PaymentMethod?
    @Binding var selectedWallet: Wallet?
    @Binding var showingOverlay: LoadingOverlayData?
    
    @FocusState private var focusedField: CardField?
    
    @EnvironmentObject var sessionStore: SessionStateStore
    @StateObject private var paymentVM: PaymentViewModel
    
    var threeDSManager: ThreeDS2Manager
    
    init(
        uiState: PaymentSheetUiState.PaymentMethods,
        selectedPaymentMethod: Binding<PaymentMethod?>,
        selectedWallet: Binding<Wallet?>,
        showingOverlay: Binding<LoadingOverlayData?>,
        threeDSManager: ThreeDS2Manager,
        paymentAPI: PaymentAPIProtocol
    ) {
        self.uiState = uiState
        self._selectedPaymentMethod = selectedPaymentMethod
        self._selectedWallet = selectedWallet
        self._showingOverlay = showingOverlay
        self.threeDSManager = threeDSManager
        
        // Initialisation du StateObject
        self._paymentVM = StateObject(wrappedValue: PaymentViewModel(paymentAPI: paymentAPI))
    }
    
    private var canPay: Bool {
        
        if let selectedPaymentMethod {
            if case .cards = selectedPaymentMethod {
                return paymentVM.formValid
            }
            
            if case .alternativePaymentMethod(let paymentMethodData) = selectedPaymentMethod {
                if let form = paymentMethodData.form, form.formType == "CUSTOM" {
                    return paymentVM.formValid
                }
            }
            
            return true
        }
        
        guard let selectedWallet else { return false }
        let walletNeedsConfirm = selectedWallet.confirm.contains(PaymentMethodData.KnownOptionsKey.cvv.rawValue)
        let issuer = Issuer.lookupIssuer(selectedWallet)
        let walletCvvValid = issuer?.rule.isValidCvv(paymentVM.cvv)
        return (!walletNeedsConfirm || walletCvvValid == true)
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            PaymentMethodsSection(
                paymentMethods: uiState.paymentMethodsList.selectablePaymentMethods,
                hasWallet: !uiState.paymentMethodsList.wallets.isEmpty,
                selectedPaymentMethod: $selectedPaymentMethod
            )
            
            if selectedPaymentMethod == nil, !uiState.paymentMethodsList.wallets.isEmpty {
                WalletSection(
                    wallets: uiState.paymentMethodsList.wallets,
                    selectedWallet: $selectedWallet,
                    walletCvv: $paymentVM.cvv,
                    focusedField: $focusedField
                )
                .transition(.move(edge: .bottom))
            }
            
            if let selectedPaymentMethod {
                
                if case .cards = selectedPaymentMethod {
                    
                    CardFormContainer(
                        sessionToken: uiState.token,
                        paymentMethod: selectedPaymentMethod,
                        viewModel: paymentVM,
                        formValid: $paymentVM.formValid
                    )
                    
                } else {
                    
                    PaymentMethodFormContainer(
                        paymentMethod: selectedPaymentMethod,
                        viewModel: paymentVM
                    )
                }
            }
            
            PayButtonSection(
                amount: uiState.amount,
                selectedPaymentMethod: selectedPaymentMethod,
                canPay: canPay,
                isLoading: paymentVM.isLoading,
                onPayTapped: makePayment
            )
        }
        .onChange(of: selectedPaymentMethod) { newPaymentMethod in
            if case let .cards(dataArr) = newPaymentMethod {
                paymentVM.cardFormViewModel = .init(
                    paymentAPI: sessionStore.getPaymentAPI(),
                    sessionToken: uiState.token,
                    paymentMethods: dataArr
                )
            } else {
                paymentVM.cardFormViewModel = nil
            }
        }
    }
    
    private func makePayment() {
        if let selectedPaymentMethod {
            makePaymentWithPaymentMethod(selectedPaymentMethod)
        } else {
            makeWalletPayment()
        }
    }
    
    private func makePaymentWithPaymentMethod(_ paymentMethod: PaymentMethod) {
        if case .cards = paymentMethod {
            makeCardPayment()
        } else {
            makeOtherPayment(paymentMethod)
        }
    }
    
    private func makeCardPayment() {
        let cardCode = paymentVM.cardFormViewModel?.derivedPaymentMethod?.cardCode
        let cardNetworkName = paymentVM.cardFormViewModel?.selectedNetwork?.network

        guard let cardInfo = getCardInfoForInitialization(cardCode: cardCode, cardNetworkName: cardNetworkName),
              !cardInfo.isEmpty else {
            Task { @MainActor in
                self.paymentVM.isLoading = false
                self.showingOverlay = nil
                print("Erreur paiement: \(PaymentError.invalidCardInfo.errorDescription ?? "")")
            }
            return
        }

        paymentVM.isLoading = true
        showingOverlay = .init(
            cardCode: cardCode,
            cardNetworkName: cardNetworkName
        )

        Task {
            do {
                if !threeDSManager.isInitialized {
                    guard let token = sessionStore.sessionState?.token else {
                        throw PaymentError.sessionTokenMissing
                    }
                    try await threeDSManager.initialize(sessionToken: token, locale: sessionStore.sessionState?.language ?? "EN", cardNetworkName: cardInfo)
                }

                guard let params = await paymentVM.buildSecuredPaymentRequest(with: threeDSManager) else {
                    throw PaymentError.invalidPaymentParameters
                }

                try await sessionStore.makeSecuredPayment(params: params)

                await MainActor.run {
                    self.paymentVM.isLoading = false
                    self.showingOverlay = nil
                }

            } catch let error as PaymentError {
                await MainActor.run {
                    self.paymentVM.isLoading = false
                    self.showingOverlay = nil
                    print("Erreur paiement: \(error.errorDescription ?? "")")
                }
            } catch {
                await MainActor.run {
                    self.paymentVM.isLoading = false
                    self.showingOverlay = nil
                    print("Erreur paiement: \(PaymentError.networkError(error).errorDescription ?? "")")
                }
            }
        }
    }
    
    private func getCardInfoForInitialization(cardCode: String?, cardNetworkName: String?) -> String? {
        switch cardCode {
        case "CB":
            return cardNetworkName
        case "AMEX":
            return cardCode
        default:
            return nil
        }
    }

    
    private func makeOtherPayment(_ paymentMethod: PaymentMethod) {
        
        guard let token = sessionStore.sessionState?.token else {
            print("Erreur paiement: \(PaymentError.sessionTokenMissing.errorDescription ?? "")")
            return
        }
        guard let paymentMethodData = paymentMethod.data else {
            print("Erreur paiement: \(PaymentError.invalidPaymentParameters.errorDescription ?? "")")
            return
        }
        
        Task {
            paymentVM.isLoading = true
            showingOverlay = .init(cardCode: paymentMethodData.cardCode, cardNetworkName: nil)
            
            do {
                let params = paymentVM.buildPaymentRequest(sessionToken: token, paymentMethodData: paymentMethodData)

                switch params {
                case .standard(let paymentRequest):
                    try await sessionStore.makePayment(params: paymentRequest)
                case .secured(let securedPaymentRequest):
                    try await sessionStore.makeSecuredPayment(params: securedPaymentRequest)
                }
                
                await MainActor.run {
                    self.paymentVM.isLoading = false
                    self.showingOverlay = nil
                }
                
            } catch let error as PaymentError {
                await MainActor.run {
                    self.paymentVM.isLoading = false
                    self.showingOverlay = nil
                    print("Erreur paiement: \(error.errorDescription ?? "")")
                }
            } catch {
                await MainActor.run {
                    self.paymentVM.isLoading = false
                    self.showingOverlay = nil
                    print("Erreur paiement: \(PaymentError.networkError(error).errorDescription ?? "")")
                }
            }
        }
    }
    
    private func makeWalletPayment() {
        focusedField = nil
        
        guard let token = sessionStore.sessionState?.token else {
            print("Erreur paiement wallet: \(PaymentError.sessionTokenMissing.errorDescription ?? "")")
            return
        }
        guard let wallet = selectedWallet else {
            print("Erreur paiement wallet: \(PaymentError.walletNotSelected.errorDescription ?? "")")
            return
        }
        if wallet.confirm.contains(PaymentMethodData.KnownOptionsKey.cvv.rawValue) && paymentVM.cvv.isEmpty {
            print("Erreur paiement wallet: \(PaymentError.walletCvvMissing.errorDescription ?? "")")
            return
        }
        
        let cardInfo = getCardInfoForInitialization(cardCode: wallet.cardCode, cardNetworkName: wallet.cardType)
        
        paymentVM.isLoading = true
        showingOverlay = .init(cardCode: wallet.cardCode, cardNetworkName: wallet.cardType)
        
        Task {
            do {
                // Initialiser 3DS seulement si c'est CB ou AMEX
                if let cardInfo = cardInfo, !cardInfo.isEmpty {
                    if !threeDSManager.isInitialized {
                        try await threeDSManager.initialize(sessionToken: token, locale: sessionStore.sessionState?.language ?? "EN", cardNetworkName: cardInfo)
                    }
                }
                
                let params = await paymentVM.buildWalletPaymentRequest(with: threeDSManager, sessionToken: token, wallet: wallet)
                try await sessionStore.makeWalletPayment(params: params)
                
                await MainActor.run {
                    self.paymentVM.isLoading = false
                    self.showingOverlay = nil
                }
                
            } catch let error as PaymentError {
                await MainActor.run {
                    self.paymentVM.isLoading = false
                    self.showingOverlay = nil
                    print("Erreur paiement wallet: \(error.errorDescription ?? "")")
                }
            } catch {
                await MainActor.run {
                    self.paymentVM.isLoading = false
                    self.showingOverlay = nil
                    print("Erreur paiement wallet: \(PaymentError.networkError(error).errorDescription ?? "")")
                }
            }
        }
    }
}
