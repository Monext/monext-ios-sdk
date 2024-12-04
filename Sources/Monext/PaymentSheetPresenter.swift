//
//  PaymentSheetPresenter.swift
//  Monext
//
//  Created by Joshua Pierce on 12/11/2024.
//
import SwiftUI
import ThreeDS_SDK

struct PaymentSheetPresenter: ViewModifier {
    
    @Binding var isPresented: Bool
    
    let sessionToken: String
    let sessionStateStore: SessionStateStore
    let onResult: (PaymentSheetResult) -> Void
    
    @State private var displayMode: DisplayMode = .compact
    @State private var sheetSize: CGSize = .zero
    @State private var currentView: ViewType = .paymentSheet
    
    var threeDSManager: ThreeDS2Manager
    @State private var challengeParameters: ChallengeParameters?
    @State private var authenticationResponse: AuthenticationResponse?
    @State private var challengeExecuted: Bool = false

    private var compactDetent: PresentationDetent {
        .height(sheetSize.height)
    }
    @State private var detents: Set<PresentationDetent> = [.large]
    @State private var selectedDetent: PresentationDetent = .large
    @State private var updatingDetentsTask: Task<Void, Never>?
    
    enum ViewType {
        case paymentSheet
        case challenge
    }
    
    init(isPresented: Binding<Bool>, sessionToken: String, sessionStateStore: SessionStateStore, onResult: @escaping (PaymentSheetResult) -> Void) {
        self._isPresented = isPresented
        self.sessionToken = sessionToken
        self.sessionStateStore = sessionStateStore
        self.onResult = onResult
        
        self.threeDSManager = ThreeDS2Manager(paymentAPI: sessionStateStore.getPaymentAPI(), uiConfig: sessionStateStore.appearance)
    }
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                ZStack {
                    
                    if #unavailable(iOS 16.4) {
                        sessionStateStore.appearance.backgroundColor.edgesIgnoringSafeArea(.all)
                    }
                    
                    switch currentView {
                    case .paymentSheet:
                        PaymentSheet(
                            sessionToken: sessionToken,
                            isPresented: $isPresented,
                            onResult: handleResult,
                            threeDSManager: threeDSManager,
                            challengeExecuted: $challengeExecuted,
                            onChallengeRequired: { parameters in
                                challengeParameters = parameters
                                challengeExecuted = true
                                switchToChallenge()
                            }
                        )
                        .modifier(GetSizeModifier(size: $sheetSize))
                        .environmentObject(sessionStateStore)
                        .environment(\.displayMode, $displayMode)
                        .environment(\.locale, Locale(identifier: sessionStateStore.sessionState?.language ?? "EN")) // Returns the value sent by the server in the response, or English by default.
                        
                        

                        
                    case .challenge:
                        if let challengeParams = challengeParameters {
                            ChallengeScreen(
                                challengeParameters: challengeParams,
                                threeDSManager: threeDSManager
                            ) { status, error in
                                handleChallengeResult(status: status, error: error)
                            }
                        }
                    }
                }
                .presentationDetents(detents, selection: $selectedDetent)
                .presentationDragIndicator(.hidden)
                .onChange(of: displayMode) { newMode in
                    if currentView == .paymentSheet {
                        updateDetents(newMode)
                    }
                }
                .onChange(of: sheetSize) { newSize in
                    if currentView == .paymentSheet && newSize != .zero {
                        updateDetents(displayMode)
                    }
                }
                .onChange(of: currentView) { newView in
                    if newView == .paymentSheet {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            updateDetents(displayMode)
                        }
                    }
                }
                .apply {
                    if #available(iOS 16.4, *) {
                        $0.presentationBackground(sessionStateStore.appearance.backgroundColor)
                    } else {
                        $0
                    }
                }
            }
    }
    
    private func handleResult(result: PaymentSheetResult) {
        if sessionStateStore.sessionState?.automaticRedirectAtSessionsEnd == true {
            isPresented = false
        }
        onResult(result)
    }
    
    private func switchToChallenge() {
        detents = [.large]
        selectedDetent = .large
        
        withAnimation(.easeInOut(duration: 0.25)) {
            currentView = .challenge
        }
    }
    
    private func switchToPaymentSheet() {
        withAnimation(.easeInOut(duration: 0.25)) {
            currentView = .paymentSheet
        }
    }
    
    private func handleChallengeResult(status: ChallengeStatus?, error: Error?) {
        if let error = error {
            print("Challenge error: \(error.localizedDescription)")
            processChallengeResult(transStatus: "U", sdkTransID: "")
            return
        }
        
        if let status = status {
            switchToPaymentSheet()
            
            switch status {
            case .completed(let completionEvent):
                print("Challenge completed successfully")
                let transStatus = completionEvent.getTransactionStatus()
                let sdkTransID = completionEvent.getSDKTransactionID()
                processChallengeResult(transStatus: transStatus, sdkTransID: sdkTransID)

            case .cancelled, .timedout,  .runtimeError:
                print("Challenge failed with status: \(status)")
                processChallengeResult(transStatus: "U", sdkTransID: "")

            case .protocolError(let protocolErrorEvent):
                processChallengeResult(transStatus: "U", sdkTransID: protocolErrorEvent.getSDKTransactionID())
            }
        }
        
        threeDSManager.closeTransaction()
        threeDSManager.cleanUp()
    }

    private func processChallengeResult(transStatus: String, sdkTransID: String) {
        guard let sdkChallengeData = sessionStateStore.sessionState?.paymentSdkChallenge?.sdkChallengeData else {
            challengeParameters = nil
            return
        }
        
        var updatedSdkChallengeData = sdkChallengeData
        updatedSdkChallengeData.transStatus = transStatus
        updatedSdkChallengeData.sdkTransID = sdkTransID
        let response = updatedSdkChallengeData.toAuthenticationResponse()
        
        challengeParameters = nil
        
        Task {
            do {
                try await sessionStateStore.makeSdkPaymentRequest(params: response)
                challengeExecuted = false
            } catch {
                print("Erreur lors du paiement SDK : \(error.localizedDescription)")
            }
        }
    }
    
    private func updateDetents(_ displayMode: DisplayMode) {
        guard currentView == .paymentSheet && sheetSize != .zero else {
            return
        }
        
        let heightDetent = compactDetent
        
        var newDetents: Set<PresentationDetent> = [.large]
        newDetents.insert(heightDetent)
        
        detents = newDetents
        
        if displayMode == .compact {
            selectedDetent = heightDetent
            didUpdateDetents(heightDetent)
        } else {
            selectedDetent = .large
            didUpdateDetents(.large)
        }
    }
      
    private func didUpdateDetents(_ detent: PresentationDetent) {
        updatingDetentsTask?.cancel()
        updatingDetentsTask = Task {
            try? await Task.sleep(for: .seconds(1))
            if Task.isCancelled { return }
            detents = [detent]
        }
    }
}
