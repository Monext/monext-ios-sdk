//
//  CardForm.swift
//  Monext
//
//  Created by Joshua Pierce on 04/12/2024.
//

import SwiftUI

enum CardField: String, CaseIterable, Hashable {
    case cardNumber, expiration, cvv, holder, networkSelector
}

struct CardForm: View {
    
    @StateObject var viewModel: CardFormViewModel
    @Binding var formValid: Bool
    
    @State private var isPresentedCvvInfo = false
    
    @FocusState private var focusedField: CardField?
    
    @EnvironmentObject var sessionStore: SessionStateStore
    @Environment(\.colorScheme) var colorScheme
    
    var onFieldFocused: ((CardField?) -> Void)?
    
    var body: some View {
        VStack(spacing: 10) {
            cardNumberField
            expirationAndCvvRow
            holderField
            networkPickerSection
            saveCardToggle
            CompliancyNotice()
        }
        .background(sessionStore.appearance.backgroundColor)
        .toolbar { keyboardToolbar }
        .onChange(of: focusedField) { field in
            viewModel.focusedField = field
            onFieldFocused?(field)
        }
        .onChange(of: viewModel.saveCard) { _ in
            focusedField = nil
        }
        .onChange(of: viewModel.selectedNetwork) { [oldValue = viewModel.selectedNetwork] _ in
            if oldValue != nil { focusedField = nil }
        }
        .onChange(of: viewModel.formValid) { isValid in
            formValid = isValid
        }
        .onChange(of: viewModel.cardExpiration) {
            if DateFormatter.isValidCardExpiration($0) { nextFocus() }
        }
    }
    
    // MARK: - Subviews
    
    private var cardNumberField: some View {
        FormFieldView<CardField>(
            label: "Card number",
            textValue: $viewModel.cardNumber,
            errorMessage: viewModel.cardNumberError,
            formatter: CardNumberFormatter(),
            keyboardType: .numberPad,
            focusedState: $focusedField,
            focusedField: .cardNumber,
            isScreenshotProtected: true
        )
        .id(CardField.cardNumber)
    }
    
    private var expirationAndCvvRow: some View {
        HStack {
            if viewModel.showExpirationDate {
                FormFieldView<CardField>(
                    label: "Expiry",
                    textValue: $viewModel.cardExpiration,
                    errorMessage: viewModel.cardExpirationError,
                    formatter: CardDateFormatter(),
                    keyboardType: .numberPad,
                    focusedState: $focusedField,
                    focusedField: .expiration,
                    isScreenshotProtected: true
                )
                .id(CardField.expiration)
            }
            if viewModel.showCardCvv {
                FormFieldView<CardField>(
                    label: "CVV",
                    textValue: $viewModel.cardCvv,
                    errorMessage: viewModel.cardCvvError,
                    formatter: CardCvvFormatter(),
                    keyboardType: .numberPad,
                    focusedState: $focusedField,
                    focusedField: .cvv,
                    onTappedInfoAccessory: { isPresentedCvvInfo = true },
                    isScreenshotProtected: true
                )
                .id(CardField.cvv)
                .modifier(CvvInfoDialog(isPresented: $isPresentedCvvInfo))
            }
        }
    }
    
    @ViewBuilder
    private var holderField: some View {
        if viewModel.showCardHolderName {
            FormFieldView<CardField>(
                label: "Name on card",
                textValue: $viewModel.cardHolderName,
                errorMessage: viewModel.cardHolderNameError,
                formatter: nil,
                focusedState: $focusedField,
                focusedField: .holder,
                isScreenshotProtected: true
            )
            .id(CardField.holder)
            .onSubmit { focusedField = nil }
            .submitLabel(.done)
        }
    }
    
    @ViewBuilder
    private var networkPickerSection: some View {
        if let availableNetworks = viewModel.availableNetworks,
           let defaultNetwork = availableNetworks.defaultCardNetwork,
           let altNetwork = availableNetworks.altCardNetwork,
           viewModel.showNetworkPicker {
            CardNetworkSelector(
                defaultNetwork: defaultNetwork,
                altNetwork: altNetwork,
                selectedNetwork: $viewModel.selectedNetwork
            )
        }
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            CardNetworkSelector(
                defaultNetwork: .init(network: "CB", code: "1"),
                altNetwork: .init(network: "VISA", code: "2"),
                selectedNetwork: .constant(.init(network: "CB", code: "1"))
            )
        }
    }
    
    @ViewBuilder
    private var saveCardToggle: some View {
        if viewModel.showSaveCard {
            ToggleButton(
                "I want to save my credit card information for later.",
                isOn: $viewModel.saveCard
            )
        }
    }
    
    @ToolbarContentBuilder
    private var keyboardToolbar: some ToolbarContent {
        if [CardField.cardNumber, CardField.expiration, CardField.cvv].contains(focusedField) {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(action: nextFocus) {
                    Text("Next")
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func nextFocus() {
        guard let focusedField else { return }
        self.focusedField = viewModel.nextFocus(focusedField)
    }
}
