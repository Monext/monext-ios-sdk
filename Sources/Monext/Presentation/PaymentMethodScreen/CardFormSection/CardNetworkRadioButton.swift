//
//  CardNetworkRadioButton.swift
//  Monext
//
//  Created by Joshua Pierce on 22/11/2024.
//

import SwiftUI

struct CardNetworkRadioButton: View {
    
    let network: CardNetwork
    let hasAlt: Bool
    
    @Binding
    var selectedNetwork: CardNetwork?
    
    @EnvironmentObject
    var sessionStore: SessionStateStore
    
    var isSelected: Bool {
        network.code == selectedNetwork?.code
    }
    
    var body: some View {
        HStack {
            
            if hasAlt {
                Image(
                    moduleImage: isSelected
                        ? "ic.radiobutton.checked"
                        : "ic.radiobutton.unchecked"
                )
                .foregroundStyle(sessionStore.appearance.onBackgroundColor)
            }
            
            ImageResolver.imageChipForCardCode(network.network)
        }
        .onTapGesture {
            selectedNetwork = network
        }
    }
}

#Preview {
    let def = CardNetwork(network: "CB", code: "2")
    let alt = CardNetwork(network: "VISA", code: "6")
    
    VStack {
        
        Spacer()
        
        HStack {
            CardNetworkRadioButton(
                network: def,
                hasAlt: true,
                selectedNetwork: .constant(def)
            )
            
            CardNetworkRadioButton(
                network: alt,
                hasAlt: true,
                selectedNetwork: .constant(def)
            )
        }
        .frame(height: 35)
        
        Spacer()
        
        CardNetworkRadioButton(
            network: def,
            hasAlt: false,
            selectedNetwork: .constant(nil)
        )
        .frame(height: 35)
        
        Spacer()
    }
    .frame(maxWidth: .infinity)
    .background(PreviewData.paymentSheetConfig.backgroundColor)
    .environmentObject(PreviewData.sessionStore)
}
