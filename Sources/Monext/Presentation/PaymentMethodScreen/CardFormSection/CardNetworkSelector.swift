//
//  CardNetworkSelector.swift
//  Monext
//
//  Created by Joshua Pierce on 22/11/2024.
//

import SwiftUI

struct CardNetwork: Equatable {
    let network: String
    let code: String
}

struct CardNetworkSelector: View {
    
    let defaultNetwork: CardNetwork
    let altNetwork: CardNetwork
    
    @Binding var selectedNetwork: CardNetwork?
    
    @State private var isPresentedInfo = false
    
    @EnvironmentObject
    var sessionStore: SessionStateStore
    
    private var config: Appearance {
        sessionStore.appearance
    }
    
    var body: some View {
        VStack {
            
            HStack {
                
                Text("Please select your preferred card network.")
                    .font(config.fonts.semibold14)
                    .foregroundStyle(config.onBackgroundColor)
                    .frame(maxWidth: .infinity)
                
                Image(moduleImage: "ic.i.circle.filled")
                    .foregroundStyle(config.textfieldAccessoryColor)
                    .onTapGesture {
                        isPresentedInfo = true
                    }
                    .modifier(CardNetworkInfoDialog(isPresented: $isPresentedInfo))
            }
            
            HStack(spacing: 24) {
            
                CardNetworkRadioButton(
                    network: defaultNetwork,
                    hasAlt: altNetwork != nil,
                    selectedNetwork: $selectedNetwork
                )
                
                CardNetworkRadioButton(
                    network: altNetwork,
                    hasAlt: true,
                    selectedNetwork: $selectedNetwork
                )
            }
            .frame(height: 38)
        }
        .padding(10)
        .background(config.textfieldBackgroundColor)
        .overlay(
            RoundedRectangle(
                cornerRadius: config.cardRadius
            )
            .stroke(
                config.textfieldBorderColor,
                lineWidth: config.textfieldStroke
            )
        )
    }
}

#Preview {
    
    let params = PreviewData.paymentSheetConfig
    let selectedNetwork = CardNetwork(network: "CB", code: "2")
    
    ZStack {
        CardNetworkSelector(
            defaultNetwork: selectedNetwork,
            altNetwork: CardNetwork(network: "VISA", code: "6"),
            selectedNetwork: .constant(selectedNetwork)
        )
        .padding(8)
    }
    .frame(maxHeight: .infinity)
    .background(PreviewData.paymentSheetConfig.backgroundColor)
    .environmentObject(PreviewData.sessionStore)
}
