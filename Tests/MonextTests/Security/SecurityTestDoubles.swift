//
//  SecurityTestDoubles.swift
//  Monext
//
//  Created by lucas bianciotto  on 29/09/2026.
//

import Foundation
@testable import Monext

final class StubSecurityCheck: SecurityCheck, @unchecked Sendable {
    private let lock = NSLock()
    private var _result: Bool
    private var _callCount = 0

    init(result: Bool) {
        _result = result
    }

    var result: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _result }
        set { lock.lock(); _result = newValue; lock.unlock() }
    }

    var callCount: Int {
        lock.lock(); defer { lock.unlock() }
        return _callCount
    }

    func check() -> Bool {
        lock.lock(); defer { lock.unlock() }
        _callCount += 1
        return _result
    }
}

struct StubDetector: CompromisedDeviceDetecting {
    let compromised: Bool
    func isCompromised() -> Bool { compromised }
}

final class MutableClock: @unchecked Sendable {
    private let lock = NSLock()
    private var current = Date(timeIntervalSince1970: 0)

    var now: Date {
        lock.lock(); defer { lock.unlock() }
        return current
    }

    func advance(by interval: TimeInterval) {
        lock.lock(); current += interval; lock.unlock()
    }
}
