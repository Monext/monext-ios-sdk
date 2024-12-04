//
//  NetceteraHelper.swift
//  Monext
//

import UIKit
@preconcurrency import ThreeDS_SDK

// MARK: - NetceteraHelper

@MainActor
final class NetceteraHelper: NSObject {
    static let shared = NetceteraHelper()
    
    private override init() {}
    
    // MARK: - Public Methods
    
    func presentChallenge(
        challengeParameters: ChallengeParameters,
        transaction: Transaction,
        completion: @escaping (ChallengeStatus?, Error?) -> Void
    ) {
        guard let topViewController = TopViewControllerProvider.getTopViewController() else {
            completion(nil, NetceteraError.noViewControllerAvailable.nsError)
            return
        }
        
        startChallenge(
            challengeParameters: challengeParameters,
            transaction: transaction,
            presentingViewController: topViewController,
            completion: completion
        )
    }
    
    // MARK: - Private Methods
    
    private func startChallenge(
        challengeParameters: ChallengeParameters,
        transaction: Transaction,
        presentingViewController: UIViewController,
        completion: @escaping (ChallengeStatus?, Error?) -> Void
    ) {
        guard presentingViewController.view.window != nil else {
            completion(nil, NetceteraError.viewControllerNotInHierarchy.nsError)
            return
        }
        
        let progressDialog = createProgressDialog(for: transaction)
        let challengeStatusReceiver = createChallengeStatusReceiver(
            progressDialog: progressDialog,
            completion: completion
        )
        
        Task {
            await performChallenge(
                transaction: transaction,
                challengeParameters: challengeParameters,
                challengeStatusReceiver: challengeStatusReceiver,
                presentingViewController: presentingViewController,
                progressDialog: progressDialog,
                completion: completion
            )
        }
    }
    
    private func createProgressDialog(for transaction: Transaction) -> ProgressDialog? {
        do {
            return try transaction.getProgressView()
        } catch {
            print("Error creating progress dialog: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func createChallengeStatusReceiver(
        progressDialog: ProgressDialog?,
        completion: @escaping (ChallengeStatus?, Error?) -> Void
    ) -> ChallengeStatusReceiverImpl {
        return ChallengeStatusReceiverImpl { status, error in
            Task { @MainActor in
                progressDialog?.stop()
                completion(status, error)
            }
        }
    }
    
    private func performChallenge(
        transaction: Transaction,
        challengeParameters: ChallengeParameters,
        challengeStatusReceiver: ChallengeStatusReceiverImpl,
        presentingViewController: UIViewController,
        progressDialog: ProgressDialog?,
        completion: @escaping (ChallengeStatus?, Error?) -> Void
    ) async {
        do {
            try transaction.doChallenge(
                challengeParameters: challengeParameters,
                challengeStatusReceiver: challengeStatusReceiver,
                timeOut: 10,
                inViewController: presentingViewController
            )
        } catch {
            await MainActor.run {
                progressDialog?.stop()
                completion(nil, error)
            }
        }
    }
}

// MARK: - TopViewControllerProvider

@MainActor
private struct TopViewControllerProvider {
    static func getTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = window.rootViewController else {
            return nil
        }
        
        return findTopViewController(from: rootViewController)
    }
    
    private static func findTopViewController(from viewController: UIViewController) -> UIViewController {
        if let presentedViewController = viewController.presentedViewController {
            return findTopViewController(from: presentedViewController)
        }
        
        if let navigationController = viewController as? UINavigationController,
           let topViewController = navigationController.topViewController {
            return findTopViewController(from: topViewController)
        }
        
        if let tabBarController = viewController as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return findTopViewController(from: selectedViewController)
        }
        
        return viewController
    }
}

// MARK: - NetceteraError

private enum NetceteraError: LocalizedError {
    case noViewControllerAvailable
    case viewControllerNotInHierarchy
    
    var errorDescription: String? {
        switch self {
        case .noViewControllerAvailable:
            return "No view controller available"
        case .viewControllerNotInHierarchy:
            return "Presenting view controller is not in the view hierarchy"
        }
    }
    
    var domain: String { "NetceteraError" }
    var code: Int {
        switch self {
        case .noViewControllerAvailable: return -1
        case .viewControllerNotInHierarchy: return -2
        }
    }
    
    var nsError: NSError {
        return NSError(
            domain: domain,
            code: code,
            userInfo: [NSLocalizedDescriptionKey: errorDescription ?? "Unknown error"]
        )
    }
}
