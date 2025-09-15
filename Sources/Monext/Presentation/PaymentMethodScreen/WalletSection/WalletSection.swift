//
//  WalletSection.swift
//  Monext
//
//  Created by Joshua Pierce on 27/11/2024.
//

import SwiftUI

struct WalletSection: View {
    
    let wallets: [Wallet]
    
    @Binding var selectedWallet: Wallet?
    @Binding var walletCvv: String
    
    var focusedField: FocusState<CardField?>.Binding
    
    @EnvironmentObject var sessionStore: SessionStateStore
    
    private var config: Appearance {
        sessionStore.appearance
    }
    
    var defaultCornersRadius: CGFloat {
        config.paymentMethodRadius
    }
    
    // NOTE: restricting wallets to max 2 until wallet feature is fully integrated
    var croppedWallets: [Wallet] {
        Array(wallets.prefix(2))
//        switch wallets.count {
//        case 0, 1, 2:
//            return wallets
//        default:
//            return [wallets.first!]
//        }
    }
    
    var hasWalletPlaceholder: Bool {
//        wallets.count > 2
        false
    }
    
    var walletPlaceholder: some View {
        WalletPlaceholderItem()
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack(alignment: .bottom, spacing: 0) {
                
                Text("Preferred payment methods")
                    .font(config.fonts.semibold14)
                    .foregroundStyle(config.onSurfaceColor)
                    .padding(.bottom, 8)
                
                Spacer()
                
                if wallets.first?.isDefault == true {
                    
                    Text("Default")
                        .font(config.fonts.semibold11)
                        .foregroundStyle(config.onPrimaryColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2.5)
                        .background(
                            UnevenRoundedRectangle(
                                cornerRadii: .init(
                                    topLeading: defaultCornersRadius,
                                    topTrailing: defaultCornersRadius
                                )
                            )
                            .fill(config.primaryColor)
                        )
                }
            }
            .padding(.trailing, 16)
            
            ForEach(croppedWallets, id: \.self) { wallet in
                WalletItem(wallet: wallet, isSelected: wallet == selectedWallet, focusedField: focusedField, cvv: $walletCvv)
                    .onTapGesture {
                        selectedWallet = wallet
                        walletCvv = ""
                    }
            }
            
            if hasWalletPlaceholder {
                walletPlaceholder
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
        .background(config.surfaceColor)
        .onAppear {
            selectedWallet = croppedWallets.first { $0.isDefault }
        }
    }
}

#Preview {
    
    let params = PreviewData.paymentSheetConfig
    
    VStack {
        
        Spacer()
        
        WalletSection(
            wallets: PreviewData.wallets,
            selectedWallet: .constant(nil),
            walletCvv: .constant(""),
            focusedField: FocusState<CardField?>().projectedValue
        )
        
        Spacer()
        
        WalletSection(
            wallets: PreviewData.wallets,
            selectedWallet: .constant(PreviewData.wallets.first!),
            walletCvv: .constant(""),
            focusedField: FocusState<CardField?>().projectedValue
        )
        
        Spacer()
    }
    .background(.gray.opacity(0.3))
    .environmentObject(PreviewData.sessionStore)
}
