import XCTest
import SwiftUI
@testable import Monext

final class CardFormViewModelTests: XCTestCase {
    
    // MARK: - Tests for showCardHolderName
    
    @MainActor
    func testHolderNameIsTrue() {
        let viewModel = CardFormTestHelper.makeCardFormViewModel(
            options: CardFormTestHelper.TestOptions.withHolder
        )
        
        XCTAssertTrue(viewModel.showCardHolderName)
    }
    
    @MainActor
    func testHolderNameIsFalse() {
        let viewModel = CardFormTestHelper.makeCardFormViewModel(
            options: CardFormTestHelper.TestOptions.base
        )
        
        XCTAssertFalse(viewModel.showCardHolderName)
    }
    
    // MARK: - Tests for showExpirationDate
    
    @MainActor
    func testExpirationDateIsTrue() {
        let viewModel = CardFormTestHelper.makeCardFormViewModel(
            options: ["EXPI_DATE", "CVV"]
        )
        
        XCTAssertTrue(viewModel.showExpirationDate)
    }
    
    @MainActor
    func testExpirationDateIsFalse() {
        let viewModel = CardFormTestHelper.makeCardFormViewModel(
            options: ["CVV", "HOLDER"]
        )
        
        XCTAssertFalse(viewModel.showExpirationDate)
    }
    
    // MARK: - Tests for showCardCvv
    
    @MainActor
    func testCardCvvIsTrue() {
        let viewModel = CardFormTestHelper.makeCardFormViewModel(
            options: CardFormTestHelper.TestOptions.cvvOnly
        )
        
        XCTAssertTrue(viewModel.showCardCvv)
    }
    
    @MainActor
    func testCardCvvIsFalse() {
        let viewModel = CardFormTestHelper.makeCardFormViewModel(
            options: CardFormTestHelper.TestOptions.holderOnly
        )
        
        XCTAssertFalse(viewModel.showCardCvv)
    }
    
    // MARK: - Tests for showSaveCard
    
    @MainActor
    func testSaveCardIsTrue() {
        let viewModel = CardFormTestHelper.makeCardFormViewModel(
            options: CardFormTestHelper.TestOptions.saveCardOnly
        )
        
        XCTAssertTrue(viewModel.showSaveCard)
    }
    
    @MainActor
    func testSaveCardIsFalse() {
        let viewModel = CardFormTestHelper.makeCardFormViewModel(
            options: CardFormTestHelper.TestOptions.cvvOnly
        )
        
        XCTAssertFalse(viewModel.showSaveCard)
    }
}
