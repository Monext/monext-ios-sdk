//
//  SuccessScreenTests.swift
//  Monext
//
//  Created by lucas bianciotto  on 03/12/2025.
//

import XCTest
import SwiftUI
import ViewInspector

@testable import Monext

// MARK: - Test Case

final class SuccessScreenTests: XCTestCase {
    
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
        let view = SuccessScreen {
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
            .view(SuccessScreen.self)
            .find(text: "Congratulations")
            .string()
        
        XCTAssertEqual(text, "Congratulations")
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
            .view(SuccessScreen.self)
            .find(text: "Ceci est un bouton de retour")
            .string()
        
        XCTAssertEqual(text, "Ceci est un bouton de retour")
    }
    
    @MainActor
    func testButtonDisplayed() throws {
        let (sut, _) = makeSUT()
        ViewHosting.host(view: sut)
        
        let text = try sut.inspect()
            .view(SuccessScreen.self)
            .find(text: "Back to the app")
            .string()
        
        XCTAssertEqual(text, "Back to the app")
    }
    
}
