//
//  LoadingOverlay.swift
//  Monext
//
//  Created by Joshua Pierce on 30/11/2024.
//

import SwiftUI

struct LoadingOverlayData {
    let cardCode: String?
    let cardNetworkName: String?
}

struct LoadingOverlay: View {
    
    let data: LoadingOverlayData
    
    @EnvironmentObject var sessionStore: SessionStateStore
    
    private var config: Appearance {
        sessionStore.appearance
    }
    
    var body: some View {
        
        VStack(spacing: 24) {
            
            if let cardNetwork = data.cardNetworkName {
                ImageResolver.imageChipForCardCode(cardNetwork)
            } else if let cardCode = data.cardCode {
                ImageResolver.imageChipForCardCode(cardCode)
            }
            
            AnimatedProgressView()
                .foregroundStyle(config.onHeaderBackgroundColor)
                .frame(width: 44, height: 44)
            
            Text("Please wait as we contact your bank.")
                .font(config.fonts.semibold20)
                .foregroundColor(config.onHeaderBackgroundColor)
                .multilineTextAlignment(.center)
        }
        .padding(44)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                stops: [
                    .init(color: config.headerBackgroundColor.opacity(0), location: 0.00),
                    .init(color: config.headerBackgroundColor, location: 0.32),
                    .init(color: config.headerBackgroundColor, location: 1.00)
                ],
                startPoint: .init(x: 0.5, y: 0),
                endPoint: .init(x: 0.5, y: 1)
            )
        )
    }
}

#Preview {
    
    VStack(spacing: 16) {
        
        Color.green
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .overlay(
                LoadingOverlay(
                    data: .init(
                        cardCode: "PAYPAL",
                        cardNetworkName: nil
                    )
                )
            )
        
        Color.red
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .overlay(
                LoadingOverlay(
                    data: .init(
                        cardCode: "CB",
                        cardNetworkName: "VISA"
                    )
                )
            )
    }
    .frame(maxHeight: .infinity)
    .background(.gray)
    .environmentObject(PreviewData.sessionStore)
}
