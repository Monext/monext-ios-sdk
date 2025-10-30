import XCTest
import SwiftUI
import ViewInspector
@testable import Monext

@MainActor
final class CardFormContainerTests: XCTestCase {

    @MainActor
    private func makeSUT(
        sessionState: SessionState? = nil
    ) -> (view: some View, store: SessionStateStore) {
        let store = SessionStateStore(
            environment: .sandbox,
            sessionState: sessionState,
            appearance: .init(),
            config: .init(),
            applePayConfiguration: .init(
                buttonLabel: .buy,
                buttonStyle: .black
            )
        )

        var formValidValue = false
        let formValidBinding = Binding<Bool>(
            get: { formValidValue },
            set: { formValidValue = $0 }
        )

        let vm = PaymentViewModel(paymentAPI: MockPaymentAPI())

        vm.cardFormViewModel = CardFormTestHelper.makeCardFormViewModel(options: CardFormTestHelper.TestOptions.all)

        let view = CardFormContainer(
            sessionToken: "Test",
            paymentMethod: .cards([CardFormTestHelper.makePaymentMethod(options: CardFormTestHelper.TestOptions.all)]),
            viewModel: vm,
            formValid: formValidBinding
        )
        .environmentObject(store)

        return (view, store)
    }

    override func tearDown() {
        ViewHosting.expel()
        super.tearDown()
    }

    func testCardFormIsVisible() throws {
        let (view, _) = makeSUT()

        // 2) Héberger la vue
        ViewHosting.host(view: AnyView(view))

        // 3) Laisser la runloop faire un tour (si publication Combine/StateObject)
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))

        // 4) Chercher directement CardForm
        XCTAssertNoThrow(
            try view.inspect().find(CardForm.self),
            "CardForm should be visible in the view hierarchy"
        )
    }
}
