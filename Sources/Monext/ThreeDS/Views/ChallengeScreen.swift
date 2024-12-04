//
//  ChallengeScreen.swift
//  Monext
//

import SwiftUI
import ThreeDS_SDK

struct ChallengeScreen: View {
    let challengeParameters: ChallengeParameters
    let threeDSManager: ThreeDS2Manager
    let onChallengeResult: (ChallengeStatus?, Error?) -> Void
    
    @State private var hasStarted = false
    
    var body: some View {
        VStack {}
            .onAppear {
                startChallengeIfNeeded()
            }
    }
    
    private func startChallengeIfNeeded() {
        guard !hasStarted else { return }
        hasStarted = true
        
        guard let transaction = threeDSManager.currentTransaction else {
            onChallengeResult(nil, ChallengeError.noActiveTransaction)
            return
        }
        
        threeDSManager.showProcessingScreen(show: true)
        
        // Délai pour permettre à l'UI de se mettre à jour
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NetceteraHelper.shared.presentChallenge(
                challengeParameters: challengeParameters,
                transaction: transaction,
                completion: onChallengeResult
            )
        }
    }
}

// MARK: - Error Handling
extension ChallengeScreen {
    enum ChallengeError: LocalizedError {
        case noActiveTransaction
        
        var errorDescription: String? {
            switch self {
            case .noActiveTransaction:
                return "Aucune transaction active"
            }
        }
    }
}
