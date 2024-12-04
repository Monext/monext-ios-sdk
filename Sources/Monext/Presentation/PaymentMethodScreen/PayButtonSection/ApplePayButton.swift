//
//  ApplePayButton.swift
//  Monext
//
//  Created by Joshua Pierce on 03/12/2024.
//

import SwiftUI
import PassKit

struct ApplePayButton: View {
    
    @EnvironmentObject var sessionStore: SessionStateStore
    
    private var sessionState: SessionState? {
        sessionStore.sessionState
    }
    
    private var paymentMethods: [PaymentMethod] {
        sessionState?.paymentMethodsList?.paymentMethods ?? []
    }
    
    private var paymentMethodData: PaymentMethodData? {
        for paymentMethod in paymentMethods {
            if case let .applePay(paymentMethodData) = paymentMethod {
                return paymentMethodData
            }
        }
        return nil
    }
    
    private var sessionInfo: SessionInfo? {
        sessionState?.info
    }
    
    private var merchantIdentifier: String {
        paymentMethodData?.additionalData.applePayMerchantId ?? ""
    }
    
    private var countryCode: String {
        sessionInfo?.merchantCountry ?? ""
    }
    
    private var currencyCode: String {
        sessionInfo?.currencyCode ?? ""
    }
    
    private var supportedNetworks: [PKPaymentNetwork] {
        (paymentMethodData?.additionalData.networks ?? [])
            .compactMap {
                PKPaymentNetwork(rawValue: $0.capitalizingFirstLetter())
            }
    }
    
    private var merchantCapabilities: PKMerchantCapability {
        let capabilitiesStr = paymentMethodData?.additionalData.merchantCapabilities ?? []
        var capabilitiesOpts: PKMerchantCapability = []
        
        // TODO: Add all supported capabilities
        for str in capabilitiesStr {
            switch str {
            case "supports3DS":
                capabilitiesOpts.insert(.threeDSecure)
            default:
                break
            }
        }
        return capabilitiesOpts
    }
    
    private var orderReference: String {
        sessionInfo?.orderRef ?? ""
    }
    
    private var orderAmount: Decimal {
        let orderAmountSmallestUnit = sessionInfo?.orderAmountSmallestUnit ?? 0
        let currencyDigits = sessionInfo?.currencyDigits ?? 0
        let divisor = max(pow(10, currencyDigits), 1)
        let adjustedOrderAmount = Decimal(orderAmountSmallestUnit) / divisor
        return adjustedOrderAmount
    }
    
    private var paymentRequest: PKPaymentRequest? {
        
        guard paymentMethodData != nil else { return nil }
        
        let paymentRequest = PKPaymentRequest()
//        paymentRequest.merchantIdentifier = "merchant.com.myluckyday.applepay"
        paymentRequest.merchantIdentifier = merchantIdentifier
        paymentRequest.countryCode = countryCode
        paymentRequest.currencyCode = currencyCode
        paymentRequest.supportedNetworks = supportedNetworks
        paymentRequest.merchantCapabilities = merchantCapabilities
        paymentRequest.paymentSummaryItems = [
            PKPaymentSummaryItem(label: orderReference, amount: orderAmount as NSDecimalNumber)
        ]
        return paymentRequest
    }
    
    @State
    private var sessionStateResult: SessionState?
    
    var body: some View {

        if let paymentRequest, PKPaymentAuthorizationController.canMakePayments(usingNetworks: paymentRequest.supportedNetworks) {

            PayWithApplePayButton(
                sessionStore.applePayConfiguration.buttonLabel,
                request: paymentRequest,
                onPaymentAuthorizationChange: authorizationChange
            ) {
                EmptyView()
//                Text("Apple Pay not supported")
            }
            .frame(height: 48)
            .payWithApplePayButtonStyle(sessionStore.applePayConfiguration.buttonStyle)
            .clipShape(RoundedRectangle(cornerRadius: sessionStore.appearance.buttonRadius))
        }
    }
}

// MARK: - Delegate methods

extension ApplePayButton {
    
    // TODO: Callback with success
    private func authorizationChange(phase: PayWithApplePayButtonPaymentAuthorizationPhase) {
        
        switch(phase) {
            
        case .willAuthorize:
            print("willAuthorize")
            
        case let .didAuthorize(payment, resultHandler):
            print("didAuthorize")
            handleApplePayDidAuthorize(payment: payment, resultHandler: resultHandler)
            
        case .didFinish:
            sessionStateResult.map {
                sessionStore.sessionState = $0
            }
            
        @unknown default:
            break
        }
    }

    private func handleApplePayDidAuthorize(payment: PKPayment, resultHandler: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        guard let sessionState else { return }
        guard let paymentMethodData else { return }
        
        guard let paymentDataJson = try? JSONDecoder().decode(ApplePaymentData.self, from: payment.token.paymentData) else { return }
        
        let params = PaymentRequest(
            cardCode: paymentMethodData.cardCode ?? "",
            merchantReturnUrl: sessionState.returnUrl ?? "",
            isEmbeddedRedirectionAllowed: false,
            paymentParams: .init(
                savePaymentData: false,
                applePayToken: .init(
                    paymentData: paymentDataJson,
                    transactionIdentifier: payment.token.transactionIdentifier,
                    paymentMethod: .init(
                        displayName: payment.token.paymentMethod.displayName ?? "",
                        type: payment.token.paymentMethod.type.stringValue,
                        network: payment.token.paymentMethod.network?.rawValue ?? ""
                    )
                )
            ),
            contractNumber: paymentMethodData.contractNumber ?? ""
        )
        
        Task {
            
            do {
                sessionStateResult = try await sessionStore.makeApplePayPayment(params: params)
                switch sessionStateResult?.type {
                case SessionType.success.rawValue:
                    resultHandler(.init(status: .success, errors: nil))
                default:
                    resultHandler(.init(status: .failure, errors: nil))
                }
            } catch {
                resultHandler(.init(status: .failure, errors: nil))
            }
        }
    }
}

#Preview {
    ApplePayButton()
        .padding()
        .environmentObject(PreviewData.sessionStore)
}

private extension PKPaymentMethodType {
    
    var stringValue: String {
        switch self {
        case .credit: return "credit"
        case .debit: return "debit"
        case .prepaid: return "prepaid"
        case .store: return "store"
        case .eMoney: return "eMoney"
        case .unknown: return "unknown"
        @unknown default: return "unknown"
        }
    }
}

private extension String {
    func capitalizingFirstLetter() -> String {
        prefix(1).uppercased() + dropFirst()
    }
}
