//
//  IssuerTests.swift
//  Monext
//
//  Created by SDK Mobile on 09/09/2025.
//

import Testing
@testable import Monext

@Test func visaTests() async throws {
    
    let testMatch = "40395867"
    let shouldMatch = Issuer.visa.rule.matches(testMatch)
    #expect(shouldMatch)
    
    let testNoMatch = "2034"
    let shouldntMatch = !Issuer.visa.rule.matches(testNoMatch)
    #expect(shouldntMatch)
}

@Test func mastercardTests() async throws {
    
    let testMatch = "5137340"
    let shouldMatch = Issuer.mastercard.rule.matches(testMatch)
    #expect(shouldMatch)
    
    let testNoMatch = "2034"
    let shouldntMatch = !Issuer.mastercard.rule.matches(testNoMatch)
    #expect(shouldntMatch)
}
