//
//  PayButtonTests.swift
//  Monext
//
//  Created by SDK Mobile on 09/07/2025.
//

import XCTest
import SwiftUI
import ViewInspector

@testable import Monext

@MainActor
final class PayButtonTests: XCTestCase {
    var sessionStore = SessionStateStore(
        environment: .sandbox,
        sessionState: nil,
        appearance: .init(),
        config: .init(),
        applePayConfiguration: .init()
    )
    
    var iDealMethod: PaymentMethod {
        .alternativePaymentMethod(
            .init(
                cardCode: "IDEAL_MNXT",
                contractNumber: "IDEAL_MNXT",
                disabled: false,
                hasForm: true,
                form: PaymentMethodForm(
                    displayButton: true,
                    description: "By choosing this payment method, you select your bank, then validate your payment. There's no need to register - your bank account is all you need to pay.",
                    buttonText: "Continue to iDeal"
                ),
                hasLogo: true,
                logo: PaymentMethodLogo(
                    width: 45,
                    height: 30,
                    url: "https://webpayment.dev.payline.com/HMI/payline-widget/pmapiresources/logo/IDEAL_MNXT/3.2-SNAPSHOT",
                    alt: "Ideal logo",
                    title: "Ideal"
                ),
                isIsolated: false,
                options: [],
                paymentMethodAction: 0,
                additionalData: AdditionalData(),
                shouldBeInTopPosition: false,
                state: "AVAILABLE"
            )
        )
    }

    func testDisplaysCorrectTitleWithoutMethod() throws {
        let sut = PayButton(
            amount: "100€",
            method: nil,
            canPay: true,
            loading: false,
            onPayTapped: {}
        ).environmentObject(sessionStore)
        
        let button = try sut.inspect().find(ViewType.Button.self)
        let text = try button.find(ViewType.Text.self).string()
        XCTAssertEqual(text, "Pay 100€")
    }
    
    func testDisplaysCorrectTitleWithMethod() throws {
        let sut = PayButton(
            amount: "100€",
            method: iDealMethod,
            canPay: true,
            loading: false,
            onPayTapped: {}
        ).environmentObject(sessionStore)
        
        let button = try sut.inspect().find(ViewType.Button.self)
        let text = try button.find(ViewType.Text.self).string()
        XCTAssertEqual(text, "Continue to iDeal")
    }
    
    func testDisplaysLoading() throws {
        let sut = PayButton(
            amount: "100€",
            method: nil,
            canPay: true,
            loading: true,
            onPayTapped: {}
        ).environmentObject(sessionStore)
        
        let button = try sut.inspect().find(ViewType.Button.self)
        XCTAssertNoThrow(try button.find(AnimatedProgressView.self))
    }
    
    func testButtonActionIsCalled() throws {
        var tapped = false
        let sut = PayButton(
            amount: "100€",
            method: nil,
            canPay: true,
            loading: false,
            onPayTapped: { tapped = true }
        ).environmentObject(sessionStore)
        
        let button = try sut.inspect().find(ViewType.Button.self)
        try button.tap()
        XCTAssertTrue(tapped)
    }
}
