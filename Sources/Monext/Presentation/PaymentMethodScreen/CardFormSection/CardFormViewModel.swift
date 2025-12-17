//
//  CardFormViewModel.swift
//  Monext
//
//  Created by Joshua Pierce on 04/12/2024.
//

import SwiftUI
import Combine

@MainActor
final class CardFormViewModel: ObservableObject {
    
    let paymentAPI: PaymentAPIProtocol
    let sessionToken: String
    let paymentMethods: [PaymentMethodData]
    
    // NOTE: show fields initially (before payment method is determined) only if the field is possible among all known card methods
    // currently only used for saveCard
    var knownOptionsSet: Set<PaymentMethodData.KnownOptionsKey> {
        paymentMethods.reduce(Set<PaymentMethodData.KnownOptionsKey>()) { partialResult, pmd in
            let pmOpts = pmd.options ?? []
            let pmOptKeys: [PaymentMethodData.KnownOptionsKey] = pmOpts.compactMap {
                for key in PaymentMethodData.KnownOptionsKey.allCases {
                    if key.rawValue == $0 { return key }
                }
                return nil
            }
            return partialResult.union(pmOptKeys)
        }
    }
    
    var derivedPaymentMethod: PaymentMethodData? {
        issuer?.correspondingPaymentMethod(paymentMethods)
    }
    
    private var paymentOptions: [String] {
        derivedPaymentMethod?.options ?? []
    }
    
    private func hasPaymentOption(key: PaymentMethodData.KnownOptionsKey) -> Bool {
        paymentOptions.contains(key.rawValue)
    }
    
    var showExpirationDate: Bool {
        if derivedPaymentMethod == nil {
            return knownOptionsSet.contains(.expirationDate)
        }
        return hasPaymentOption(key: .expirationDate)
    }
    
    var showCardCvv: Bool {
        if derivedPaymentMethod == nil {
            return knownOptionsSet.contains(.cvv)
        }
        return hasPaymentOption(key: .cvv)
    }
    
    var showNetworkPicker: Bool {
        guard derivedPaymentMethod != nil else { return true }
        return hasPaymentOption(key: .alternativeNetwork)
    }
    
    var showCardHolderName: Bool {
        if derivedPaymentMethod == nil {
            return knownOptionsSet.contains(.cardHolder)
        }
        return hasPaymentOption(key: .cardHolder)
    }
    
    var showSaveCard: Bool {
        if derivedPaymentMethod == nil {
            return knownOptionsSet.contains(.saveCard)
        }
        return hasPaymentOption(key: .saveCard)
    }
    
    @Published var cardNumber: String = ""
    @Published var cardNumberError: LocalizedStringKey?
    
    @Published var cardExpiration: String = ""
    @Published var cardExpirationError: LocalizedStringKey?
    
    @Published var cardCvv: String = ""
    @Published var cardCvvError: LocalizedStringKey?
    
    @Published var cardHolderName: String = ""
    @Published var cardHolderNameError: LocalizedStringKey?
    
    @Published var focusedField: CardField?
    
    @Published internal var issuer: Issuer?
    
    @Published var availableNetworks: AvailableCardNetworksResponse?
    
    @Published var selectedNetwork: CardNetwork?
    
    @Published var saveCard: Bool = false
    
    @Published var formValid: Bool = false
    
    private var subscribers = Set<AnyCancellable>()
    private let actor: CardFormViewModelActor
    
    init(paymentAPI: PaymentAPIProtocol, sessionToken: String, paymentMethods: [PaymentMethodData]) {
        
        self.paymentAPI = paymentAPI
        self.sessionToken = sessionToken
        self.paymentMethods = paymentMethods
        
        self.actor = CardFormViewModelActor(paymentAPI: paymentAPI)
        
        setupCardNumberSubscriptions()
        setupCvvSubscriptions()
        setupCardExpirationSubscriptions()
        setupCardHolderSubscriptions()
        
        $issuer
            .sink { [weak self] in
                if $0 == nil {
                    self?.selectedNetwork = nil
                }
                if let pm = $0?.correspondingPaymentMethod(self?.paymentMethods ?? []) {
                    self?.saveCard = pm.additionalData.savePaymentDataChecked ?? false
                }
                self?.validateForm(
                    cardCvv: self?.cardCvv,
                    cardExpiration: self?.cardExpiration,
                    cardHolderName: self?.cardHolderName,
                    cardNumber: self?.cardNumber
                )
            }
            .store(in: &subscribers)
    }
    
    func nextFocus(_ focusedField: CardField) -> CardField? {
        switch focusedField {
        case .cardNumber:
            if showExpirationDate { return .expiration }
            if showCardCvv { return .cvv }
            if showCardHolderName { return .holder }
            return nil
        case .expiration:
            if showCardCvv { return .cvv }
            if showCardHolderName { return .holder }
            return nil
        case .cvv:
            if showCardHolderName { return .holder }
            return nil
        default:
            return nil
        }
    }
    
    private func validateForm(cardCvv: String?, cardExpiration: String?, cardHolderName: String?, cardNumber: String?) {
        let isValid = isValidForm(
            cardCvv: cardCvv ?? "",
            cardExpiration: cardExpiration ?? "",
            cardHolderName: cardHolderName ?? "",
            cardNumber: cardNumber ?? ""
        )
        formValid = isValid
    }
    
    private func isValidForm(cardCvv: String, cardExpiration: String, cardHolderName: String, cardNumber: String) -> Bool {
        
        guard let issuer else { return false }
        guard derivedPaymentMethod != nil else { return false }
        
        if hasPaymentOption(key: .cvv) && !issuer.rule.isValidCvv(cardCvv) {
            return false
        }
        
        if hasPaymentOption(key: .expirationDate) && !DateFormatter.isValidCardExpiration(cardExpiration) {
            print(cardExpiration)
            return false
        }
        
        // NOTE: I don't think we need this because if network is not selected Monext will use the defaultNetwork
//        if hasPaymentOption(key: .alternativeNetwork) && (selectedNetwork == nil || selectedNetwork!.isEmpty) {
//            return false
//        }
        
        if hasPaymentOption(key: .cardHolder) && cardHolderName.isEmpty {
            return false
        }
        
        return issuer.rule.isValidCardNumber(cardNumber)
    }
    
    func buildPaymentRequest(with threeDSManager: ThreeDS2Manager) async -> SecuredPaymentRequest? {
        guard formValid else { return nil }
        guard let paymentMethod = derivedPaymentMethod else { return nil }
        
        let timezone = TimeZone.current
        let secondsDiff = timezone.secondsFromGMT()
        let minutesDiff = Double(secondsDiff) / 60.0
        let minutesDiffRounded = Int(minutesDiff.rounded(.down))
        
        // Générer les données du contexte SDK 3DS
        let sdkContextData = await threeDSManager.generateSDKContextDataSync()
        
        // Créer les paramètres de paiement avec les données 3DS
        let paymentParams = PaymentParams(
            network: selectedNetwork?.code ?? "",
            expirationDate: cardExpiration.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression),
            savePaymentData: saveCard,
            holderName: cardHolderName,
            sdkContextData: sdkContextData
        )
        
        return SecuredPaymentRequest(
            cardCode: paymentMethod.cardCode ?? "",
            contractNumber: paymentMethod.contractNumber ?? "",
            deviceInfo: DeviceInfo(
                colorDepth: 32, // No native color depth API (Apple)
                containerHeight: getContainerHeight(),
                containerWidth: getContainerWidth(),
                javaEnabled: false,
                screenHeight: Int(UIScreen.main.bounds.height.rounded(.down)),
                screenWidth: Int(UIScreen.main.bounds.width.rounded(.down)),
                timeZoneOffset: minutesDiffRounded
            ),
            isEmbeddedRedirectionAllowed: true,
            merchantReturnUrl: paymentAPI.returnURLString(sessionToken: sessionToken),
            paymentParams: paymentParams,
            securedPaymentParams: SecuredPaymentParams(
                pan: cardNumber,
                cvv: cardCvv
            )
        )
    }
    
    private func getContainerHeight() -> Double {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return Double(window.frame.height)
        }
        return Double(UIScreen.main.bounds.height)
    }

    private func getContainerWidth() -> Double {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return Double(window.frame.width)
        }
        return Double(UIScreen.main.bounds.width)
    }
}

// MARK: - Card Number

extension CardFormViewModel {
    
    private func setupCardNumberSubscriptions() {
        
        // Format number
        let uniqueCardNumber = $cardNumber.removeDuplicates()
        
        // Issuer Lookup
        uniqueCardNumber
            .map { String($0.prefix(10)) }
            .removeDuplicates()
            .map { Issuer.lookupIssuer($0) }
            .sink { [weak self] issuer in
                self?.issuer = issuer
            }
            .store(in: &subscribers)
        
        // Available Card Networks
        uniqueCardNumber
            .handleEvents(receiveOutput: { [weak self] newNumber in
                // NOTE: when we are under the digit threshold we need to remove availableNetworks
                if newNumber.count < 6 {
                    self?.availableNetworks = nil
                }
            })
            .filter { $0.count >= 6 }
            .map { String($0.prefix(10)) }
            .removeDuplicates()
            .debounce(for: .seconds(0.6), scheduler: RunLoop.main)
            .map { newNumber in
                Future { promise in
                    Task {
                        let response = await self.actor.fetchAvailableCardNetworks(
                            String(newNumber),
                            sessionToken: self.sessionToken,
                            paymentMethods: self.paymentMethods
                        )
                        promise(.success(response))
                    }
                }
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cardNetworksResponse in
                self?.availableNetworks = cardNetworksResponse
                self?.selectedNetwork = cardNetworksResponse?.defaultCardNetwork
            }
            .store(in: &subscribers)
        
        // Number field validation error message
        uniqueCardNumber
            .combineLatest($focusedField, $issuer)
            .filter { (number, _, _) in number.count > 0 }
            .map { (number, focusedField, issuer) -> LocalizedStringKey? in
                if focusedField == .cardNumber { return nil }
                if let issuer {
                    if !issuer.rule.isValidCardNumber(number) {
                        return "Invalid Card Number"
                    }
                } else {
                    return "Unknown card type"
                }
                return nil
            }
            .sink { [weak self] errorMsg in
                self?.cardNumberError = errorMsg
            }
            .store(in: &subscribers)
        
        uniqueCardNumber
            .sink { [weak self] in
                self?.validateForm(
                    cardCvv: self?.cardCvv,
                    cardExpiration: self?.cardExpiration,
                    cardHolderName: self?.cardHolderName,
                    cardNumber: $0
                )
            }
            .store(in: &subscribers)
    }
}

// MARK: - CVV

extension CardFormViewModel {
    
    private func setupCvvSubscriptions() {
        
        $cardCvv
            .combineLatest($focusedField, $issuer)
            .filter { (cvv, _, _) in cvv.count > 0 }
            .map { (cvv, focusedField, issuer) -> LocalizedStringKey? in
                if focusedField == .cvv { return nil }
                if let issuer {
                    if !issuer.rule.isValidCvv(cvv) {
                        return "Invalid CVV"
                    }
                }
                return nil
            }
            .sink { [weak self] errorMsg in
                self?.cardCvvError = errorMsg
            }
            .store(in: &subscribers)
        
        $cardCvv
            .sink { [weak self] in
                self?.validateForm(
                    cardCvv: $0,
                    cardExpiration: self?.cardExpiration,
                    cardHolderName: self?.cardHolderName,
                    cardNumber: self?.cardNumber
                )
            }
            .store(in: &subscribers)
    }
}

// MARK: - Expiration

extension CardFormViewModel {
    
    private func setupCardExpirationSubscriptions() {
        
        let uniqueCardExpiration = $cardExpiration
            .removeDuplicates()
        
        uniqueCardExpiration
            .combineLatest($focusedField)
            .filter { (expiration, _) in expiration.count > 0 }
            .map { (expiration, focusedField) -> LocalizedStringKey? in
                
                guard !(focusedField == .expiration) else { return nil }
                
                if let _ = DateFormatter.cardNetworkFormat.date(from: expiration) {
                    if DateFormatter.isValidCardExpiration(expiration) {
                        return nil
                    } else {
                        return "Invalid Expiration Date"
                    }
                }
                return "Invalid Format"
            }
            .sink { [weak self] errorMsg in
                self?.cardExpirationError = errorMsg
            }
            .store(in: &subscribers)
        
        uniqueCardExpiration
            .sink { [weak self] in
                self?.validateForm(
                    cardCvv: self?.cardCvv,
                    cardExpiration: $0,
                    cardHolderName: self?.cardHolderName,
                    cardNumber: self?.cardNumber
                )
            }
            .store(in: &subscribers)
    }
}

// MARK: - Card Holder
extension CardFormViewModel {
    
    private func setupCardHolderSubscriptions() {
        $cardHolderName
            .sink { [weak self] in
                self?.validateForm(
                    cardCvv: self?.cardCvv,
                    cardExpiration: self?.cardExpiration,
                    cardHolderName: $0,
                    cardNumber: self?.cardNumber
                )
            }
            .store(in: &subscribers)
    }
}

// MARK: - Actors

actor CardFormViewModelActor {
    private var paymentAPI: PaymentAPIProtocol
    
    
    init(paymentAPI: PaymentAPIProtocol) {
        self.paymentAPI = paymentAPI
    }
    
    func fetchAvailableCardNetworks(_ cardNumber: String, sessionToken: String, paymentMethods: [PaymentMethodData]) async -> AvailableCardNetworksResponse? {
        
        do {
            let contracts = paymentMethods
                .filter { $0.cardCode != nil && $0.contractNumber != nil }
                .map {
                    HandledContract(
                        cardCode: $0.cardCode!,
                        contractNumber: $0.contractNumber!
                    )
                }
            
            guard !contracts.isEmpty else { return nil }
            
            let params = AvailableCardNetworksRequest(
                cardNumber: cardNumber,
                handledContracts: contracts
            )
            
            return try await paymentAPI.availableCardNetworks(sessionToken: sessionToken, params: params)
            
        } catch {
            paymentAPI.sendError(message: error.localizedDescription, url: "", token: sessionToken, loggerName: "CardFormViewModelActor")
            print(error)
            return nil
        }
    }
}
