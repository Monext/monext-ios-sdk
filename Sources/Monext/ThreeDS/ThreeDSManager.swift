//
//  ThreeDSManager.swift
//  Monext
//
//  Updated with SDK context data generation
//
import Foundation
import ThreeDS_SDK
import SwiftUI

@MainActor
class ThreeDS2Manager: ObservableObject {
    @Published var isInitialized = false
    @Published var isLoading = false
    @Published var warnings: [String] = []
    @Published var challengeStatus: ChallengeStatus?
    @Published var challengeError: Error?
    @Published var currentTransaction: ThreeDS_SDK.Transaction?
    
    var sessionStore: SessionStateStore?
    
    private var threeDS2Service: ThreeDS2Service?
    private var paymentAPI: PaymentAPIProtocol
    private var uiConfig: Appearance

    private var directoryServerId: String?
    
    private(set) var sessionToken: String?
    
    private let isDevelopmentMode: Bool
    
    var onChallengeCompleted: ((ChallengeStatus?, Error?) -> Void)?
    
    init(threeDS2Service: ThreeDS2Service? = ThreeDS2ServiceSDK(), paymentAPI: PaymentAPIProtocol, uiConfig: Appearance = Appearance()) {
        self.threeDS2Service = threeDS2Service
        self.paymentAPI = paymentAPI
        self.uiConfig = uiConfig
        
        self.isDevelopmentMode = paymentAPI.getEnvironment().isSandbox()
    }
    
    func fetchSchemes(sessionToken: String) async throws -> [SchemeData] {
        let response = try await paymentAPI.fetchSchemes(sessionToken: sessionToken)
        let schemes = response.directoryServerSdkKeyList
        
        return schemes.map { remoteScheme in
            let scheme = Scheme(
                name: remoteScheme.scheme,
                ids: [remoteScheme.rid],
                logoImageName: nil,
                encryption: remoteScheme.publicKey,
                encryptionKeyId: nil,
                roots: [remoteScheme.rootPublicKey]
            )
            
            return SchemeData(
                name: remoteScheme.scheme,
                rid: remoteScheme.rid,
                scheme: scheme
            )
        }
    }
    
    func getSchemeForCardCode(_ cardNetworkName: String) throws -> Scheme {
        switch cardNetworkName {
        case "CB":
            directoryServerId = DsRidValues.cartesBancaires
            return Scheme.cb()
        case "VISA":
            directoryServerId = DsRidValues.visa
            return Scheme.visa()
        case "MASTERCARD":
            directoryServerId = DsRidValues.mastercard
            return Scheme.mastercard()
        case "AMEX":
            directoryServerId = DsRidValues.amex
            return Scheme.amex()
        default:
            throw SchemeError.unsupportedCardCode(cardNetworkName)
        }
    }
    
    func resolveScheme(for cardNetworkName: String, sessionToken: String?) async throws -> Scheme {
        if isDevelopmentMode {
            guard let token = sessionToken else {
                throw ThreeDS2Error.SDKNotInitialized(message: "No session token", cause: nil)
            }
            
            let schemes = try await fetchSchemes(sessionToken: token)
            
            if let matchingScheme = schemes.first(where: { $0.name == cardNetworkName }) {
                directoryServerId = matchingScheme.scheme.ids?.first ?? nil
                
                return matchingScheme.scheme
            } else {
                throw ThreeDS2Error.InvalidData(message: "No scheme found for card code: \(cardNetworkName)")
            }
        } else {
            let scheme = try getSchemeForCardCode(cardNetworkName)
            return scheme
        }
    }
    
    func initialize(sessionToken: String?, locale: String, cardNetworkName: String) async throws {
        guard let service = threeDS2Service else { return }
        
        self.sessionToken = sessionToken
        isLoading = true
        
        do {
            let uiCustomization = try ThreeDS2UICustomization.createUICustomization(uiConfig: uiConfig)
            let scheme = try await resolveScheme(for: cardNetworkName, sessionToken: sessionToken)
            let configParameters = try ThreeDS2Configuration.createConfigParameters(schemes: [scheme])
            
            // Utilisation de withCheckedContinuation pour convertir le callback en async/await
            try await withCheckedThrowingContinuation { continuation in
                service.initialize(
                    configParameters,
                    locale: locale,
                    uiCustomizationMap: [
                        "DEFAULT": uiCustomization
                    ],
                    success: { [weak self] in
                        DispatchQueue.main.async {
                            self?.isInitialized = true
                            self?.isLoading = false
                            self?.loadWarnings()
                            continuation.resume()
                        }
                    },
                    failure: { [weak self] error in
                        DispatchQueue.main.async {
                            self?.isLoading = false
                            self?.loadWarnings()
                            self?.paymentAPI.sendError(message: "Erreur d'initialisation: \(error.localizedDescription)", url: nil, token: self?.sessionToken, loggerName: "ThreeDSManager")
                            continuation.resume(throwing: error)
                        }
                    }
                )
            }
        } catch {
            await MainActor.run {
                isLoading = false
            }
            self.paymentAPI.sendError(message: "Erreur de configuration: \(error.localizedDescription)", url: nil, token: self.sessionToken, loggerName: "ThreeDSManager")
            throw error
        }
    }
    
    
    // MARK: - Transaction Management
    func createTransaction() async throws -> ThreeDS_SDK.Transaction {
        guard let service = threeDS2Service, isInitialized else {
            throw ThreeDS2Error.SDKNotInitialized(message: "SDK non initialisé", cause: nil)
        }
        
        guard let directoryServerId = directoryServerId else {
            throw ThreeDS2Error.InvalidData(message: "Directory Server ID non configuré")
         }
        
        isLoading = true
        
        do {
            let transaction = try service.createTransaction(
                directoryServerId: directoryServerId,
                messageVersion: ThreeDS2Configuration.messageVersion
            )
            
            currentTransaction = transaction
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            return transaction
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.paymentAPI.sendError(message: "Erreur création transaction: \(error.localizedDescription)", url: nil, token: self.sessionToken, loggerName: "ThreeDSManager")
            }
            throw error
        }
    }
    
    // MARK: - Generate SDK Context Data
    func generateSDKContextData() async throws -> SDKContextData {
        guard isInitialized else {
            throw ThreeDS2Error.SDKNotInitialized(message: "SDK non initialisé", cause: nil)
        }
                
        let transaction = try await createTransaction()
        let authParams = try transaction.getAuthenticationRequestParameters()

        // Transformer les données de la clé publique
        let ephemeralPublicKeyData = try DeviceDataTransformer.transformDeviceData(authParams.getSDKEphemeralPublicKey())

        // Générer les données du contexte SDK
        let sdkContextData = SDKContextData(
            deviceRenderingOptionsIF: "01", //TODO: on verra avec la spec EMVCo ce qu'on met par défaut
            deviceRenderOptionsUI: "03", // TODO: on verra avec la spec EMVCo ce qu'on met par défaut
            maxTimeout: 60,
            referenceNumber: authParams.getSDKReferenceNumber(),
            ephemPubKey: ephemeralPublicKeyData,
            appID: authParams.getSDKAppID(),
            transID: authParams.getSDKTransactionId(),
            encData: authParams.getDeviceData()
        )
        
        return sdkContextData
    }
    
    // Version synchrone pour compatibilité UI
    func generateSDKContextDataSync() async -> SDKContextData? {
        do {
            return try await generateSDKContextData()
        } catch {
            DispatchQueue.main.async {
                self.paymentAPI.sendError(message: "Erreur génération contexte SDK: \(error.localizedDescription)", url: nil, token: self.sessionToken, loggerName: "ThreeDSManager")
            }
            return nil
        }
    }
    
    
    func showProcessingScreen(show: Bool) {
        guard let transaction = currentTransaction else {
            print("Cannot show processing screen: no current transaction")
            return
        }
        
        do {
            let progressDialog = try transaction.getProgressView()
            show ? progressDialog.start() : progressDialog.stop()
        } catch {
            paymentAPI.sendError(message: "Error showing progress dialog: \(error.localizedDescription)", url: nil, token: sessionToken, loggerName: "ThreeDSManager")
        }
    }
    
        
    func closeTransaction() {
        guard let transaction = currentTransaction else {
            print("Tentative de fermeture d'une transaction déjà fermée")
            return
        }
        
        do {
            try transaction.close()
        } catch {
            paymentAPI.sendError(message: "Erreur lors de la fermeture de la transaction: \(error.localizedDescription)", url: nil, token: sessionToken, loggerName: "ThreeDSManager")
        }
        
        currentTransaction = nil
    }
    
    func cleanUp() {
        guard let service = threeDS2Service else { return }
        
        do {
            try service.cleanup()
        } catch {
            paymentAPI.sendError(message: "Erreur lors du nettoyage du service: \(error)", url: nil, token: sessionToken, loggerName: "ThreeDSManager")
        }
    }
    
    // MARK: - Warnings
    private func loadWarnings() {
        guard let service = threeDS2Service else { return }
        
        do {
            let sdkWarnings = try service.getWarnings()
            warnings = sdkWarnings.map { warning in
                "[\(warning.getSeverity())] \(warning.getMessage())"
            }
        } catch {
            paymentAPI.sendError(message: "Erreur lors de la récupération des warnings: \(error)", url: nil, token: sessionToken, loggerName: "ThreeDSManager")
        }
    }
}
