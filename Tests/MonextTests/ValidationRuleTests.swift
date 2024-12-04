//
//  Validation.swift
//  Monext
//
//  Created by Joshua Pierce on 21/11/2024.
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

@Test func luhnAlogrithmTests() async throws {
    
    let testCardsValid = [
    
        // VISA
        "4929939187355598",
        "4485383550284604",
        "4532307841419094",
        "4716014929481859",
        "4539677496449015",

        // Mastercard
        "5454422955385717",
        "5582087594680466",
        "5485727655082288",
        "5523335560550243",
        "5128888281063960",

        // Discover
        "6011574229193527",
        "6011908281701522",
        "6011638416335074",
        "6011454315529985",
        "6011123583544386",

        // AMEX
        "348570250878868",
        "341869994762900",
        "371040610543651",
        "341507151650399",
        "371673921387168"
    ]
    
    for num in testCardsValid {
        assert(num.passesLuhnCheck())
    }
    
    let testCardsInvalid = [
    
        // VISA
        "4129939187355598",
        "4485383550184604",
        "4532307741419094",
        "4716014929401859",
        "4539672496449015",

        // Mastercard
        "5454452295585717",
        "5582087594683466",
        "5487727655082288",
        "5523335500550243",
        "5128888221063960",

        // Discover
        "6011574229193127",
        "6031908281701522",
        "6011638416335054",
        "6011454316529985",
        "6011123581544386",

        // AMEX
        "348570250872868",
        "341669994762900",
        "371040610573651",
        "341557151650399",
        "371673901387168"
    ]
    
    for num in testCardsInvalid {
        assert(!num.passesLuhnCheck())
    }
}
