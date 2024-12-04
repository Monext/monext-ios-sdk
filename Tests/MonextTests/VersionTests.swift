//
//  VersionTests.swift
//  Monext
//
//  Created by SDK Mobile on 15/05/2025.
//

import XCTest
@testable import Monext

class VersionTests: XCTestCase {

    func testVersionComparison() {
        // Test de la méthode isNewerThan
        XCTAssertTrue("1.2.3".compare("1.1.0", options: .numeric) == .orderedDescending)
        XCTAssertTrue("2.0.0".compare("1.9.9", options: .numeric) == .orderedDescending)
        XCTAssertFalse("1.0.0".compare("1.0.1", options: .numeric) == .orderedDescending)
        
        // Vérifier que les versions sont accessibles
        XCTAssertFalse(AppVersion.marketingVersion.isEmpty)
    }
    
    func testFullVersionFormat() {
        // Vérifier le format de la version complète
        let fullVersion = AppVersion.fullVersion
        XCTAssertTrue(fullVersion.contains("v"))
        if !AppVersion.buildNumber.isEmpty {
            XCTAssertTrue(fullVersion.contains("("))
            XCTAssertTrue(fullVersion.contains(")"))
        }

    }
}
