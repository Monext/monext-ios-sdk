import Foundation
@preconcurrency import ThreeDS_SDK

/// Implémentation du receiver pour le challenge Netcetera 3DS2.
public class ChallengeStatusReceiverImpl: NSObject, ChallengeStatusReceiver {
    private let callback: (ChallengeStatus?, Error?) -> Void

    public init(callback: @escaping (ChallengeStatus?, Error?) -> Void) {
        self.callback = callback
    }

    public func completed(completionEvent: ThreeDS_SDK.CompletionEvent) {
        callback(.completed(completionEvent), nil)
    }

    public func cancelled() {
        callback(.cancelled, nil)
    }

    public func timedout() {
        callback(.timedout, nil)
    }

    public func protocolError(protocolErrorEvent: ThreeDS_SDK.ProtocolErrorEvent) {
        print(protocolErrorEvent.getErrorMessage())
        callback(.protocolError(protocolErrorEvent), nil)
    }

    public func runtimeError(runtimeErrorEvent: ThreeDS_SDK.RuntimeErrorEvent) {
        print(runtimeErrorEvent.getErrorMessage())
        callback(.runtimeError(runtimeErrorEvent), nil)
    }
}
