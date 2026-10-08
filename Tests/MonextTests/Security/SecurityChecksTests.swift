//
//  SecurityChecksTests.swift
//  Monext
//
//  Created by lucas bianciotto  on 29/09/2026.
//

import XCTest
import Network
@testable import Monext

final class SecurityChecksTests: XCTestCase {

    // MARK: - Simulateur

    func testFileSystemChecksAreSkippedOnSimulator() throws {
        #if targetEnvironment(simulator)
        XCTAssertFalse(BinaryCheck().check())
        XCTAssertFalse(PackageCheck().check())
        XCTAssertFalse(DylibCheck().check())
        XCTAssertFalse(SymlinkCheck().check())
        #else
        throw XCTSkip("Uniquement sur simulateur")
        #endif
    }

    // MARK: - SymlinkCheck

    func testSymlinkRelativeDestinationsOfCleanDeviceAreExpected() {
        let sut = SymlinkCheck()

        XCTAssertFalse(sut.isUnexpectedDestination("private/etc", for: "/etc"))
        XCTAssertFalse(sut.isUnexpectedDestination("private/var", for: "/var"))
        XCTAssertFalse(sut.isUnexpectedDestination("private/var/tmp", for: "/tmp"))
    }

    func testSymlinkAbsoluteDestinationsAreExpected() {
        let sut = SymlinkCheck()

        XCTAssertFalse(sut.isUnexpectedDestination("/private/etc/", for: "/etc"))
        XCTAssertFalse(sut.isUnexpectedDestination("/var", for: "/var"))
    }

    func testSymlinkRedirectedDestinationIsSuspicious() {
        let sut = SymlinkCheck()

        XCTAssertTrue(sut.isUnexpectedDestination("/var/jb/etc", for: "/etc"))
        XCTAssertTrue(sut.isUnexpectedDestination("private/var/mobile", for: "/var"))
    }

    func testSymlinkUnknownPathIsIgnored() {
        XCTAssertFalse(SymlinkCheck().isUnexpectedDestination("/anywhere", for: "/usr"))
    }

    // MARK: - DylibCheck

    func testDylibCheckDetectsHookingFrameworks() {
        let sut = DylibCheck()

        XCTAssertTrue(sut.containsSuspiciousImage(["/usr/lib/libSystem.B.dylib", "/Library/MobileSubstrate/MobileSubstrate.dylib"]))
        XCTAssertTrue(sut.containsSuspiciousImage(["/private/var/containers/Bundle/App/FRIDAGADGET.dylib"]))
        XCTAssertTrue(sut.containsSuspiciousImage(["/var/jb/usr/lib/libhooker.dylib"]))
    }

    func testDylibCheckIgnoresSystemImages() {
        let sut = DylibCheck()

        XCTAssertFalse(sut.containsSuspiciousImage([]))
        XCTAssertFalse(sut.containsSuspiciousImage([
            "/usr/lib/libSystem.B.dylib",
            "/System/Library/Frameworks/SwiftUI.framework/SwiftUI"
        ]))
    }

    // MARK: - FridaCheck

    func testFridaCheckReturnsFalseWhenPortIsClosed() {
        XCTAssertFalse(FridaCheck(port: 1).check())
    }

    func testFridaCheckReturnsTrueWhenPortIsOpen() throws {
        let listener = try NWListener(using: .tcp, on: .any)
        listener.newConnectionHandler = { $0.start(queue: .global()) }
        let ready = expectation(description: "listener ready")
        listener.stateUpdateHandler = { state in
            if case .ready = state { ready.fulfill() }
        }
        listener.start(queue: .global())
        defer { listener.cancel() }
        wait(for: [ready], timeout: 2)

        let port = try XCTUnwrap(listener.port)

        XCTAssertTrue(FridaCheck(port: port, timeout: 2).check())
    }
}
