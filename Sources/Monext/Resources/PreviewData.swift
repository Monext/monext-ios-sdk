//
//  PreviewData.swift
//  Monext
//
//  Created by Joshua Pierce on 14/01/2025.
//

import SwiftUI

struct PreviewData {
    
//    static let paymentSheetConfig = paymentSheetConfigSampleDefault
    static let paymentSheetConfig = paymentSheetConfigSampleDark
    
    private static let paymentSheetConfigSampleDefault = Appearance(
        headerTitle: "Monext Demo"
    )
    
    private static let paymentSheetConfigSampleDark: Appearance = {
        
        let primary = Color((162, 56, 255))
        let textfield = Color((170, 164, 175))
        
        return Appearance(
            
            primaryColor: primary,
            onPrimaryColor: .white,
            secondaryColor: primary,
            onSecondaryColor: .white,
            backgroundColor: Color((15, 13, 19)),
            onBackgroundColor: .white,
            surfaceColor: Color((27, 25, 31)),
            onSurfaceColor: .white,
            confirmationColor: Color((64, 207, 176)),
            onConfirmationColor: .white,
            errorColor: Color((221, 32, 37)),
            
            textfieldLabelColor: textfield,
            textfieldTextColor: .white,
            textfieldBorderColor: textfield.opacity(0.2),
            textfieldBorderSelectedColor: primary,
            textfieldBackgroundColor: textfield.opacity(0.15),
            textfieldAccessoryColor: .white.opacity(0.3),
            
            buttonRadius: 12,
            cardRadius: 12,
            textfieldRadius: 10,
            textfieldStroke: 0,
            textfieldStrokeSelected: 2,
            paymentMethodShape: .round,
            
            headerTitle: "MONEXT DARK",
            headerBackgroundColor: Color((27, 25, 31)),
            onHeaderBackgroundColor: .white
        )
    }()
    
    @MainActor
    static let sessionStore: SessionStateStore = {
        .init(
            environment: .sandbox,
            sessionState: Self.sessionState,
            appearance: Self.paymentSheetConfig,
            config: .init(),
            applePayConfiguration: .init(
                buttonLabel: .buy,
                buttonStyle: .black
            )
        )
    }()
    
    static let sessionState: SessionState = {
        .init(
            token: "",
            type: "PAYMENT_METHODS_LIST",
            info: Self.sessionInfo,
            paymentMethodsList: .init(
                isOriginalCreditTransfer: false,
                needsDeviceFingerprint: false,
                paymentMethodsData: Self.paymentMethodData,
                scoringNeeded: false,
                sensitiveInputContentMasked: false,
                shouldChangePaymentMethodPosition: false,
                wallets: Self.wallets
            ),
            paymentRedirectNoResponse: .init(
                cardCode: "CB",
                contractNumber: "CB_FAKE",
                redirectionData: .init(
                    hasPartnerLogo: false,
                    iframeEmbeddable: false,
                    iframeHeight: 1,
                    iframeWidth: 1,
                    isCompletionMethod: false,
                    requestType: "",
                    requestUrl: "https://localhost.local",
                    timeoutInMs: 12,
                    requestFields: [:]
                ),
                walletCardIndex: nil
            ),
            paymentOnholdPartner: PaymentOnholdPartner(
                message: CustomMessage(
                    type: "CUSTOM",
                    localizedMessage: "<p>Hello <strong>World</strong></p>",
                    displayIcon: true
                ),
                selectedCardCode: "PAYPAL_APIREST",
                selectedContractNumber: "PAYPAL_APIREST"
            ),
            paymentSuccess: .init(
                displayTicket: true,
                fragmented: false,
                paymentCard: "Cartes Bancaires",
                selectedCardCode: "CB",
                selectedContractNumber: "CB_FAKE",
                ticket: [
                    .init(
                        interline: false,
                        key: "Date and time",
                        style: nil,
                        t: 0,
                        value: "ON 26/11/2024 AT  20:08 CET"
                    ),
                    .init(
                        interline: false,
                        key: "Store",
                        style: nil,
                        t: 0,
                        value: "POS_Fake"
                    ),
                    .init(
                        interline: true,
                        key: "URL address",
                        style: nil,
                        t: 0,
                        value: "WWW.FAKESTORE.COM"
                    ),
                    .init(
                        interline: false,
                        key: "Card number",
                        style: nil,
                        t: 0,
                        value: " 4970 10XX XXXX XX19"
                    ),
                    .init(
                        interline: false,
                        key: "Terminal/Acceptor",
                        style: nil,
                        t: 0,
                        value: "001 60 185 658 219 108"
                    ),
                    .init(
                        interline: true,
                        key: "Transaction number",
                        style: nil,
                        t: 0,
                        value: "15330190830710"
                    ),
                    .init(
                        interline: false,
                        key: "Transaction type",
                        style: nil,
                        t: 0,
                        value: "DEBIT VADS @"
                    ),
                    .init(
                        interline: false,
                        key: "AUTHORIZATION NUMBER",
                        style: "ticketNumAutorization",
                        t: 0,
                        value: "A55A"
                    ),
                    .init(
                        interline: true,
                        key: "AMOUNT \u{003d} ",
                        style: "ticketAmount",
                        t: 0,
                        value: "26,65 EUR"
                    ),
                    .init(
                        interline: true,
                        key: "Reference ",
                        style: nil,
                        t: 0,
                        value: "TEST_70"
                    ),
                    .init(
                        interline: true,
                        key: nil,
                        style: "ticketTestCard",
                        t: 0,
                        value: "TEST CARD"
                    ),
                    .init(
                        interline: false,
                        key: nil,
                        style: "ticketKeep",
                        t: 0,
                        value: "CUSTOMER RECIPT TO KEEP"
                    )
                ]
            )
        )
    }()
    
    private static let sessionInfo = SessionInfo(
        amountSmallestUnit: 2665,
        buyerIp: "127.0.0.1",
        currencyCode: "EUR",
        currencyDigits: 2,
        formattedAmount: "EUR26.65",
        formattedOrderAmount: "EUR26.65",
        merchantCountry: "FR",
        orderAmountSmallestUnit: 2665,
        orderDate: "11/26/2024 20:07",
        orderDeliveryMode: "",
        orderDeliveryTime: "",
        orderRef: "TEST_70"
    )
    
    static let paymentMethodData: [PaymentMethodData] = [
        .init(
            cardCode: "CB",
            contractNumber: "CB_FAKE",
            disabled: false,
            hasForm: false,
            form: nil,
            hasLogo: false,
            logo: nil,
            isIsolated: false,
            options: [ "EXPI_DATE", "CVV", "ALT_NETWORK", "HOLDER" ],
            paymentMethodAction: 0,
            additionalData: .init(
                merchantCapabilities: nil,
                networks: nil,
                applePayMerchantId: nil,
                applePayMerchantName: nil
            ),
            shouldBeInTopPosition: false,
            state: "AVAILABLE"
        ),
        .init(
            cardCode: "AMEX",
            contractNumber: "AMEX_FAKE",
            disabled: false,
            hasForm: false,
            form: nil,
            hasLogo: false,
            logo: nil,
            isIsolated: false,
            options: [ "EXPI_DATE", "CVV" ],
            paymentMethodAction: 0,
            additionalData: .init(
                merchantCapabilities: nil,
                networks: nil,
                applePayMerchantId: nil,
                applePayMerchantName: nil
            ),
            shouldBeInTopPosition: false,
            state: "AVAILABLE"
        ),
        .init(
            cardCode: "IDEAL",
            contractNumber: "IDEAL_FAKE",
            disabled: false,
            hasForm: false,
            form: nil,
            hasLogo: false,
            logo: nil,
            isIsolated: false,
            options: [],
            paymentMethodAction: 0,
            additionalData: .init(
                merchantCapabilities: nil,
                networks: nil,
                applePayMerchantId: nil,
                applePayMerchantName: nil
            ),
            shouldBeInTopPosition: false,
            state: "AVAILABLE"
        ),
        .init(
            cardCode: "PAYPAL",
            contractNumber: "PAYPAL_FAKE",
            disabled: false,
            hasForm: false,
            form: nil,
            hasLogo: false,
            logo: nil,
            isIsolated: false,
            options: [],
            paymentMethodAction: 0,
            additionalData: .init(
                merchantCapabilities: nil,
                networks: nil,
                applePayMerchantId: nil,
                applePayMerchantName: nil
            ),
            shouldBeInTopPosition: false,
            state: "AVAILABLE"
        ),
        .init(
            cardCode: "APPLE_PAY",
            contractNumber: "APPLE_PAY_FAKE",
            disabled: false,
            hasForm: false,
            form: nil,
            hasLogo: false,
            logo: nil,
            isIsolated: false,
            options: [],
            paymentMethodAction: 0,
            additionalData: .init(
                merchantCapabilities: ["supports3DS"],
                networks: [
                    "cartesBancaires",
                    "visa",
                    "mastercard"
                ],
                applePayMerchantId: "60185658219108.1.APPLE_PAY",
                applePayMerchantName: "MyLuckyDay"
            ),
            shouldBeInTopPosition: true,
            state: "AVAILABLE"
        )
    ]
    
    static let paymentMethods: [PaymentMethod] = {
        var group = [PaymentMethod]()
        var cardsArray: [PaymentMethodData] = []
        for pm in PreviewData.paymentMethodData {
            if pm.isCard {
                cardsArray.append(pm)
            } else {
                if let individual = PaymentMethod.forIndividualPaymentMethod(pm) {
                    group.append(individual)
                }
            }
        }
        if !cardsArray.isEmpty {
            group.insert(.cards(cardsArray), at: 0)
        }
        return group
    }()
    
    static let wallets: [Wallet] = [
        .init(
            additionalData: AdditionalData(date: "1125", holder: "", pan: "###-XX19"),
            cardCode: "CB",
            cardType: "CB",
            confirm: ["CVV"],
            customLogoRatio: 0,
            expiredMore6Months: false,
            hasCustomLogo: false,
            hasCustomLogoBase64: false,
            hasCustomLogoUrl: false,
            hasSpecificDisplay: false,
            index: 1,
            isDefault: true,
            isExpired: false,
            isPmAPI: false,
            options: []
        ),
        .init(
            additionalData: AdditionalData(date: "0926", holder: "LEIA ORGANA", pan: "###-XX25"),
            cardCode: "VISA",
            cardType: "VISA",
            confirm: [],
            customLogoRatio: 0,
            expiredMore6Months: false,
            hasCustomLogo: false,
            hasCustomLogoBase64: false,
            hasCustomLogoUrl: false,
            hasSpecificDisplay: false,
            index: 2,
            isDefault: false,
            isExpired: false,
            isPmAPI: false,
            options: []
        ),
        .init(
            additionalData: AdditionalData(date: "0129", holder: "GOLD LEADER", pan: "###-XX90"),
            cardCode: "MASTERCARD",
            cardType: "MASTERCARD",
            confirm: [],
            customLogoRatio: 0,
            expiredMore6Months: false,
            hasCustomLogo: false,
            hasCustomLogoBase64: false,
            hasCustomLogoUrl: false,
            hasSpecificDisplay: false,
            index: 3,
            isDefault: false,
            isExpired: false,
            isPmAPI: false,
            options: []
        ),
        .init(
            additionalData: .init(email: "luke.skywalker@tatooine.com"),
            cardCode: "PAYPAL",
            cardType: "PAYPAL",
            confirm: [],
            customLogoRatio: 0,
            expiredMore6Months: false,
            hasCustomLogo: false,
            hasCustomLogoBase64: false,
            hasCustomLogoUrl: false,
            hasSpecificDisplay: false,
            index: 4,
            isDefault: false,
            isExpired: false,
            isPmAPI: false,
            options: []
        ),
    ]
}
