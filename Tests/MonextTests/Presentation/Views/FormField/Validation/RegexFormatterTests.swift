//
//  RegexFormatterTests.swift
//  Monext
//
//  Created by SDK Mobile on 09/09/2025.
//

import XCTest
@testable import Monext

final class RegexFormatterTests: XCTestCase {
    
    func testMaxLength() {
        let f = RegexFormatter(pattern: "[0-9]+", maxLength: 4)
        XCTAssertEqual(f.format("123456"), "1234")
    }
    
    func testFullMatch() {
        let f = RegexFormatter(pattern: "[A-Z]{3}[0-9]{2}")
        XCTAssertTrue(f.isValid("ABC12"))
        XCTAssertFalse(f.isValid("ABC123"))
        XCTAssertFalse(f.isValid("XX12"))
    }
    
    func testPartialAllowed() {
        let f = RegexFormatter(pattern: "[0-9]{2}", requiresFullMatch: false)
        XCTAssertTrue(f.isValid("x12y"))
    }
    
    func testTransform() {
        let f = RegexFormatter(
            pattern: "[A-Z]{4}[0-9]{2}",
            preValidationTransform: { $0.replacingOccurrences(of: "-", with: "").uppercased() }
        )
        XCTAssertTrue(f.isValid("ab-cd12"))
    }
    
    func testInvalidPattern() {
        let f = RegexFormatter(pattern: "[Unclosed")
        XCTAssertFalse(f.isValid("whatever"))
    }
    
    func testIbanLike() {
        let f = RegexFormatter(
            pattern: "[A-Z0-9]{15,34}",
            preValidationTransform: { $0.replacingOccurrences(of: " ", with: "").uppercased() }
        )
        XCTAssertTrue(f.isValid("fr76 3000 6000 0112 3456 7890 189"))
        XCTAssertFalse(f.isValid("FR76 !!")) // caractères invalides
    }
}
