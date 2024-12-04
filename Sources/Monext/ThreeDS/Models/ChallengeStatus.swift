//
//  ChallengeStatus.swift
//  Monext
//
//  Created by SDK Mobile on 18/07/2025.
//

import Foundation
@preconcurrency import ThreeDS_SDK

public enum ChallengeStatus: Sendable {
    case completed(ThreeDS_SDK.CompletionEvent)
    case cancelled
    case timedout
    case protocolError(ThreeDS_SDK.ProtocolErrorEvent)
    case runtimeError(ThreeDS_SDK.RuntimeErrorEvent)
}

extension ChallengeStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .completed:
            return "completed"
        case .cancelled:
            return "cancelled"
        case .timedout:
            return "timedout"
        case .protocolError:
            return "protocolError"
        case .runtimeError:
            return "runtimeError"
        }
    }
}
