//
//  RootDetectorTests.swift
//  Monext
//
//  Created by lucas bianciotto  on 29/09/2026.
//

import XCTest
@testable import Monext

final class RootDetectorTests: XCTestCase {

    func testIsNotCompromisedWhenAllChecksPass() {
        let sut = RootDetector(checks: [StubSecurityCheck(result: false), StubSecurityCheck(result: false)])

        XCTAssertFalse(sut.isCompromised())
    }

    func testIsCompromisedWhenOneCheckFails() {
        let sut = RootDetector(checks: [StubSecurityCheck(result: false), StubSecurityCheck(result: true)])

        XCTAssertTrue(sut.isCompromised())
    }

    func testIsNotCompromisedWithoutChecks() {
        XCTAssertFalse(RootDetector(checks: []).isCompromised())
    }

    func testStopsAtFirstFailingCheck() {
        let failing = StubSecurityCheck(result: true)
        let next = StubSecurityCheck(result: false)
        let sut = RootDetector(checks: [failing, next])

        _ = sut.isCompromised()

        XCTAssertEqual(next.callCount, 0)
    }

    func testResultIsCachedWithinTTL() {
        let clock = MutableClock()
        let check = StubSecurityCheck(result: false)
        let sut = RootDetector(checks: [check], cacheTTL: 30, now: { clock.now })

        XCTAssertFalse(sut.isCompromised())
        check.result = true
        clock.advance(by: 29)

        XCTAssertFalse(sut.isCompromised())
        XCTAssertEqual(check.callCount, 1)
    }

    func testResultIsRefreshedAfterTTL() {
        let clock = MutableClock()
        let check = StubSecurityCheck(result: false)
        let sut = RootDetector(checks: [check], cacheTTL: 30, now: { clock.now })

        XCTAssertFalse(sut.isCompromised())
        check.result = true
        clock.advance(by: 30)

        XCTAssertTrue(sut.isCompromised())
        XCTAssertEqual(check.callCount, 2)
    }

    func testConcurrentCallsAreSafe() {
        let sut = RootDetector(checks: [StubSecurityCheck(result: true)], cacheTTL: 0)

        DispatchQueue.concurrentPerform(iterations: 100) { _ in
            XCTAssertTrue(sut.isCompromised())
        }
    }

    func testSharedDetectorIsNotCompromisedInDebug() {
        XCTAssertFalse(RootDetector.shared.isCompromised())
    }
}
