//
//  WalletItem.swift
//  Monext
//
//  Created by Joshua Pierce on 28/11/2024.
//

import SwiftUI

struct WalletItem: View {
    
    let wallet: Wallet
    
    var isSelected: Bool
    
    let focusedField: FocusState<CardField?>.Binding
    
    @Binding var cvv: String
    
    private var errorMessage: LocalizedStringKey? {
        guard !cvv.isEmpty else { return nil }
        guard !(focusedField.wrappedValue == .cvv) else { return nil }
        guard let issuer = Issuer.lookupIssuer(wallet) else { return nil }
        guard !issuer.rule.isValidCvv(cvv) else { return nil }
        return "Invalid CVV"
    }
    
    @EnvironmentObject var sessionStore: SessionStateStore
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isPresentedCvvInfo = false
    
    private var config: Appearance {
        sessionStore.appearance
    }
    
    var email: String? {
        wallet.additionalData.email
    }
    
    var holder: String? {
        wallet.additionalData.holder
    }
    
    var topText: String? {
        if let holder, !holder.isEmpty {
            return holder
        }
        return email
    }
    
    var showsBottomText: Bool {
        let maskedNumberPresent = maskedNumber?.isEmpty == false
        let cardDatePresent = cardDate?.isEmpty == false
        return maskedNumberPresent || cardDatePresent
    }
    
    var maskedNumber: String? {
        wallet.additionalData.pan.map {
            $0.replacing(/[^\d]/, with: "\u{2022}")
        }
    }
    
    var cardDate: String? {
        guard let rawDateStr = wallet.additionalData.date else { return nil }
        guard let date = DateFormatter.cardNetworkFormat.date(from: rawDateStr) else { return nil }
        return DateFormatter.cardPresentationFormat.string(from: date)
    }
    
    var body: some View {
        
        VStack(spacing: 16) {
            
            HStack(spacing: 10) {
                
                ImageResolver.imageChipForCardCode(wallet.cardType)
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    if let topText {
                        HStack {
                            
                            Text(topText)
                                .font(config.fonts.semibold14)
                                .foregroundStyle(config.onSurfaceColor)
                            
                            Spacer()
                        }
                    }
                    
                    if showsBottomText {
                        HStack(spacing: 16) {
                            
                            if let maskedNumber {
                                Text(maskedNumber)
                                    .font(config.fonts.semibold14)
                                    .foregroundStyle(config.onSurfaceCardNumber)
                            }
                            
                            Spacer()
                            
                            if let cardDate {
                                Text("Exp. \(cardDate)")
                                    .font(config.fonts.semibold14)
                                    .foregroundStyle(config.onSurfaceColor)
                            }
                        }
                    }
                }
                .frame(maxWidth:  .infinity)
                
                Group {
                    if isSelected {
                        Image(moduleImage: "ic.radiobutton.checked")
                    } else {
                        Image(moduleImage: "ic.radiobutton.unchecked")
                    }
                }
                .foregroundStyle(config.primaryColor)
            }
            
            if isSelected && wallet.confirm.contains(PaymentMethodData.KnownOptionsKey.cvv.rawValue) {
                FormFieldView(
                    label: "CVV",
                    textValue: $cvv,
                    errorMessage: errorMessage,
                    formatter: CardCvvFormatter(),
                    useOnSurfaceStyle: true,
                    keyboardType: .numberPad,
                    focusedState: focusedField,
                    focusedField: .cvv,
                    onTappedInfoAccessory: { isPresentedCvvInfo = true }
                )
                .modifier(CvvInfoDialog(isPresented: $isPresentedCvvInfo))
                .toolbar {
                    if focusedField.wrappedValue == CardField.cvv {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button(action: { focusedField.wrappedValue = nil }) {
                                Text("Next")
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                            }
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(isSelected ? config.primaryAlpha : .clear)
        .background(config.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: config.cardRadius))
        .overlay(
            RoundedRectangle(
                cornerRadius: config.cardRadius
            )
            .stroke(style: StrokeStyle(lineWidth: isSelected ? 2 : 1))
            .foregroundStyle(
                isSelected
                    ? config.primaryColor
                    : config.onSurfaceAlpha
            )
        )
        .padding(.bottom, 8)
    }
}

#Preview {
    
    VStack {
        
        Spacer()
        
        WalletItem(
            wallet: PreviewData.wallets.first!,
            isSelected: true,
            focusedField: FocusState<CardField?>().projectedValue,
            cvv: .constant("")
        )
        
        Spacer()
        
        WalletItem(
            wallet: PreviewData.wallets[1],
            isSelected: false,
            focusedField: FocusState<CardField?>().projectedValue,
            cvv: .constant("")
        )
        
        Spacer()
        
        WalletItem(
            wallet: PreviewData.wallets[3],
            isSelected: false,
            focusedField: FocusState<CardField?>().projectedValue,
            cvv: .constant("")
        )
        
        Spacer()
    }
    .background(Color(white: 0.8))
    .environmentObject(PreviewData.sessionStore)
}
