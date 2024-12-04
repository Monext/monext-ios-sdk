//
//  MonextConfigTests.swift
//  Monext
//
//  Created by SDK Mobile on 29/08/2025.
//

import XCTest
@testable import Monext

final class MonextConfigTests: XCTestCase {
    
    func testNetecteraAPIKey() {
        let key = MonextConfig.NetecteraAPIKey
        XCTAssertNotNil(key)
    }

    
}
