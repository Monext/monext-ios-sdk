//
//  DialogViewTests.swift
//  Monext
//
//  Created by lucas bianciotto  on 28/07/2026.
//


import XCTest
import SwiftUI
@testable import Monext
 
@MainActor
class DialogViewTests: XCTestCase {
 
    // Le délai async interne d'ExitPaymentDialog vaut `animationDuration` (0.4s),
    // déclaré `fileprivate` dans DialogView.swift et donc non accessible ici.
    // On attend un peu plus long pour laisser le asyncAfter se résoudre.
    private let asyncDelay: TimeInterval = 0.4
    private let waitTimeout: TimeInterval = 1.0
 
    // MARK: - Helpers
 
    /// Construit un ExitPaymentDialog avec un binding `isPresented` piloté par une closure,
    /// afin d'observer sa mutation depuis le test (le modifier ne touche pas `sessionStore`
    /// dans `dismiss`, donc pas besoin d'environnement).
    private func makeDialog(
        isPresented: @escaping () -> Bool,
        setPresented: @escaping (Bool) -> Void,
        onExit: @escaping () -> Void
    ) -> ExitPaymentDialog {
        ExitPaymentDialog(
            isPresented: Binding(get: isPresented, set: setPresented),
            onExit: onExit
        )
    }
 
    // MARK: - Exit (notifyOnExit: true)
 
    /// Le bouton "Exit" doit notifier via onExit ET fermer le dialog.
    func testExitButtonNotifiesOnExitAndDismisses() {
        // Given
        let onExitCalled = expectation(description: "onExit doit être appelé")
        var isPresented = true
 
        let dialog = makeDialog(
            isPresented: { isPresented },
            setPresented: { isPresented = $0 },
            onExit: { onExitCalled.fulfill() }
        )
 
        // When
        dialog.dismiss(notifyOnExit: true)
 
        // Then
        wait(for: [onExitCalled], timeout: waitTimeout)
        XCTAssertFalse(isPresented, "Le dialog doit être fermé après Exit")
    }
 
    // MARK: - Stay (notifyOnExit: false)
 
    /// Le bouton "Stay" ne doit jamais notifier onExit, mais doit fermer le dialog.
    func testStayButtonDoesNotNotifyButDismisses() {
        // Given
        var notified = false
        var isPresented = true
 
        let dialog = makeDialog(
            isPresented: { isPresented },
            setPresented: { isPresented = $0 },
            onExit: { notified = true }
        )
 
        // When
        dialog.dismiss(notifyOnExit: false)
 
        // Then : on laisse passer le délai async pour vérifier qu'onExit N'EST PAS appelé
        let settled = expectation(description: "délai async écoulé")
        DispatchQueue.main.asyncAfter(deadline: .now() + asyncDelay + 0.2) {
            settled.fulfill()
        }
        wait(for: [settled], timeout: waitTimeout)
 
        XCTAssertFalse(notified, "Stay ne doit jamais notifier onExit")
        XCTAssertFalse(isPresented, "Le dialog doit quand même se fermer après Stay")
    }
 
    // MARK: - Idempotence / ordre
 
    /// onExit ne doit être appelé qu'une seule fois pour un seul Exit.
    func testExitNotifiesExactlyOnce() {
        // Given
        var callCount = 0
        var isPresented = true
 
        let dialog = makeDialog(
            isPresented: { isPresented },
            setPresented: { isPresented = $0 },
            onExit: { callCount += 1 }
        )
 
        // When
        dialog.dismiss(notifyOnExit: true)
 
        // Then
        let settled = expectation(description: "délai async écoulé")
        DispatchQueue.main.asyncAfter(deadline: .now() + asyncDelay + 0.2) {
            settled.fulfill()
        }
        wait(for: [settled], timeout: waitTimeout)
 
        XCTAssertEqual(callCount, 1, "onExit ne doit être appelé qu'une fois")
    }
}
 
