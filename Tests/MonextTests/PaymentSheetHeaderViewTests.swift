//
//  PaymentSheetHeaderViewTests.swift
//  Monext
//
//  Created by lucas bianciotto  on 28/07/2026.
//


import XCTest
import SwiftUI
import ViewInspector
@testable import Monext
 
@MainActor
final class PaymentSheetHeaderViewTests: BaseAPITestCase {
 
    private let mockToken = "1cEtH2D3ogZsaJ4PE1531746023359858"
 
    override func setUp() {
        super.setUp()
        Task { await MockURLProtocol.clearHandler() }
        setupAPI()
    }
 
    override func tearDown() {
        Task { await MockURLProtocol.clearHandler() }
        super.tearDown()
    }
 
    // MARK: - Helpers
 
    /// Construit un store dont la session est dans l'état correspondant au JSON fourni.
    private func makeStore(jsonFileName: String) async throws -> SessionStateStore {
        let store = createSessionStateStore()
        clearMockResponses()
 
        try await withCheckedThrowingContinuation { continuation in
            Task {
                await setupMockResponse(
                    for: mockToken,
                    endpoint: "state/current",
                    jsonFileName: jsonFileName
                )
                continuation.resume()
            }
        }
 
        try await store.updateSessionState(token: mockToken)
        return store
    }
 
    private func makeHeader(
        store: SessionStateStore,
        isPresented: Binding<Bool>,
        onResult: @escaping (PaymentSheetResult) -> Void
    ) -> some View {
        PaymentSheetHeaderView(isPresented: isPresented, onResult: onResult)
            .environmentObject(store)
    }
 
    // MARK: - Routing du bouton de fermeture
 
    /// Dans un état terminal (ex. succès), le "X" ferme directement la sheet,
    /// SANS repasser par le dialog et SANS émettre .paymentSheetDismissedByUser.
    func testCloseInTerminalStateDismissesWithoutResult() async throws {
        let store = try await makeStore(jsonFileName: "PaymentSuccess")
 
        var captured: PaymentSheetResult?
        var isPresentedValue = true
        let binding = Binding(get: { isPresentedValue }, set: { isPresentedValue = $0 })
 
        let header = makeHeader(store: store, isPresented: binding) { captured = $0 }
 
        try header.inspect().find(ViewType.Button.self).tap()
 
        XCTAssertFalse(isPresentedValue, "La sheet doit se fermer directement en état terminal")
        XCTAssertNil(captured, "Aucun résultat ne doit être émis lors d'une fermeture en état terminal")
    }
 
    /// En PAYMENT_METHODS_LIST, le "X" n'émet rien et ne ferme pas : il ouvre le dialog
    /// de confirmation. Donc isPresented reste vrai et aucun résultat n'est émis à ce stade.
    func testCloseInPaymentMethodsStateOpensDialogInsteadOfDismissing() async throws {
        let store = try await makeStore(jsonFileName: "PaymentMethodList")
 
        var captured: PaymentSheetResult?
        var isPresentedValue = true
        let binding = Binding(get: { isPresentedValue }, set: { isPresentedValue = $0 })
 
        let header = makeHeader(store: store, isPresented: binding) { captured = $0 }
 
        try header.inspect().find(ViewType.Button.self).tap()
 
        XCTAssertTrue(isPresentedValue, "Le X ne doit pas fermer la sheet : il ouvre le dialog de confirmation")
        XCTAssertNil(captured, "Aucun résultat ne doit être émis tant que l'utilisateur n'a pas confirmé")
    }
 
    // MARK: - Confirmation de sortie -> .paymentSheetDismissedByUser
 
    /// Quand l'utilisateur confirme la sortie, le header câble onExit pour émettre
    /// .paymentSheetDismissedByUser ET fermer la sheet.
    ///
    /// On récupère l'ExitPaymentDialog câblé par le header et on déclenche son onExit
    /// (équivalent au tap sur "Exit", déjà couvert par DialogViewTests).
    func testExitConfirmationEmitsDismissedByUser() async throws {
        let store = try await makeStore(jsonFileName: "PaymentMethodList")
 
        var captured: PaymentSheetResult?
        var isPresentedValue = true
        let binding = Binding(get: { isPresentedValue }, set: { isPresentedValue = $0 })
 
        let header = makeHeader(store: store, isPresented: binding) { captured = $0 }
 
        let dialog = try header.inspect()
            .find(ViewType.Button.self)
            .modifier(ExitPaymentDialog.self)
            .actualView()
 
        dialog.onExit()
 
        guard case .paymentSheetDismissedByUser = captured else {
            return XCTFail("Résultat attendu .paymentSheetDismissedByUser, obtenu \(String(describing: captured))")
        }
        XCTAssertFalse(isPresentedValue, "isPresented doit passer à false après confirmation")
    }
}
