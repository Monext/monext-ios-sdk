//
//  PendingScreenTests.swift
//  Monext
//
//  Created by SDK Mobile on 09/09/2025.
//

import XCTest
import SwiftUI
import ViewInspector

@testable import Monext

// MARK: - Test Case

final class PendingScreenTests: XCTestCase {
    
    @MainActor
    private func makeSUT(
        sessionState: SessionState? = nil,
        appearance: Appearance = .init(),
        onExitCalled: UnsafeMutablePointer<Bool>? = nil
    ) -> (view: some View, store: SessionStateStore) {
        let store = SessionStateStore(
            environment: .sandbox,
            sessionState: sessionState,
            appearance: appearance,
            config: .init(),
            applePayConfiguration: .init(
                buttonLabel: .buy,
                buttonStyle: .black
            )
        )
        var closureCalled = false
        let view = PendingScreen {
            closureCalled = true
            onExitCalled?.pointee = true
        }.environmentObject(store)
        
        if let ptr = onExitCalled {
            ptr.pointee = closureCalled
        }
        return (view, store)
    }
    
    override func tearDown() {
        ViewHosting.expel()
        super.tearDown()
    }
    
    @MainActor
    func testTitleIsDisplayed() throws {
        let (sut, _) = makeSUT()
        ViewHosting.host(view: sut)
        
        let text = try sut.inspect()
            .view(PendingScreen.self)
            .find(text: "Payment pending")
            .string()
        
        XCTAssertEqual(text, "Payment pending")
    }
    
    @MainActor
    func testFallbackMessageDisplayedWhenNoHtml() throws {
        let state = SessionState(
            token: "TestToken",
            type: "PAYMENT_ONHOLD_PARTNER",
            paymentOnholdPartner: PaymentOnholdPartner(
                message: CustomMessage(
                    type: "CUSTOM",
                    localizedMessage: "",
                    displayIcon: false
                ),
                selectedCardCode: "CB",
                selectedContractNumber: "12345"
            )
        )
        let (sut, _) = makeSUT(sessionState: state)
        ViewHosting.host(view: sut)
        
        let text = try sut.inspect()
            .view(PendingScreen.self)
            .find(text: "Payment pending")
            .string()
        
        XCTAssertEqual(text, "Payment pending")
        
       let description = try sut.inspect()
           .view(PendingScreen.self)
           .find(text: "Your payment is pending. Please contact your merchant for further information.")
           .string()
        
        XCTAssertEqual(description, "Your payment is pending. Please contact your merchant for further information.")
    }
    
    @MainActor
    func testAttributedMessageDisplayedWhenHtmlPresent() throws {
        let state = SessionState(
            token: "TestToken",
            type: "PAYMENT_ONHOLD_PARTNER",
            paymentOnholdPartner: PaymentOnholdPartner(
                message: CustomMessage(
                    type: "CUSTOM",
                    localizedMessage: "<p>Hello <strong>World</strong></p>",
                    displayIcon: true
                ),
                selectedCardCode: "PAYPAL_APIREST",
                selectedContractNumber: "PAYPAL_APIREST"
            )
        )
        let (sut, _) = makeSUT(sessionState: state)
        ViewHosting.host(view: sut)
        
        // Utiliser l'accessibilityIdentifier pour trouver le bon Text
        let text = try sut.inspect()
            .view(PendingScreen.self)
            .find(text: "Hello World")
            .string()
        
        XCTAssertEqual(text, "Hello World")
    }
    
    @MainActor
    func testCustomButtonDisplayed() throws {
        let (sut, _) = makeSUT(
            appearance: .init(
                backButtonText: "Ceci est un bouton de retour"
            )
        )
        ViewHosting.host(view: sut)
        
        let text = try sut.inspect()
            .view(PendingScreen.self)
            .find(text: "Ceci est un bouton de retour")
            .string()
        
        XCTAssertEqual(text, "Ceci est un bouton de retour")
    }
    
    @MainActor
    func testButtonDisplayed() throws {
        let (sut, _) = makeSUT()
        ViewHosting.host(view: sut)
        
        let text = try sut.inspect()
            .view(PendingScreen.self)
            .find(text: "Back to the app")
            .string()
        
        XCTAssertEqual(text, "Back to the app")
    }
    
}
