//
//  SecurityPaymentSheetPresenterTests.swift
//  Monext
//
//  Created by lucas bianciotto  on 29/09/2026.
//

import XCTest
import SwiftUI
@testable import Monext

@MainActor
final class SecurityPaymentSheetPresenterTests: XCTestCase {

    private var isPresented = false

    private func makeSUT(compromised: Bool) -> SecurityPaymentSheetPresenter {
        SecurityPaymentSheetPresenter(
            isPresented: Binding(get: { self.isPresented }, set: { self.isPresented = $0 }),
            sessionToken: "TOKEN",
            sessionStateStore: SessionStateStore(
                environment: .sandbox,
                appearance: Appearance(),
                config: .init(),
                applePayConfiguration: ApplePayConfiguration()
            ),
            detector: StubDetector(compromised: compromised),
            onResult: { _ in }
        )
    }

    func testSheetIsPresentedOnCleanDevice() {
        let sut = makeSUT(compromised: false)

        isPresented = true
        sut.handlePresentationChange(true)

        XCTAssertTrue(isPresented)
        XCTAssertTrue(sut.securedPresentation.wrappedValue)
    }

    func testSheetIsNeverPresentedOnCompromisedDevice() {
        let sut = makeSUT(compromised: true)

        isPresented = true

        XCTAssertFalse(sut.securedPresentation.wrappedValue)
    }

    func testOpeningIsCancelledOnCompromisedDevice() {
        let sut = makeSUT(compromised: true)

        isPresented = true
        sut.handlePresentationChange(true)

        XCTAssertFalse(isPresented)
    }

    func testClosingIsIgnoredOnCompromisedDevice() {
        let sut = makeSUT(compromised: true)

        isPresented = false
        sut.handlePresentationChange(false)

        XCTAssertFalse(isPresented)
    }

    func testDismissingThroughSecuredBindingUpdatesIsPresented() {
        let sut = makeSUT(compromised: false)

        isPresented = true
        sut.securedPresentation.wrappedValue = false

        XCTAssertFalse(isPresented)
    }

}
