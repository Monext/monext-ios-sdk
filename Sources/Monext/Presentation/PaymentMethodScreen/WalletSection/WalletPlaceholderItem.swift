//
//  WalletPlaceholderItem.swift
//  Monext
//
//  Created by Joshua Pierce on 11/12/2024.
//

import SwiftUI

struct WalletPlaceholderItem: View {
    
    @EnvironmentObject var sessionStore: SessionStateStore
    
    private var config: Appearance {
        sessionStore.appearance
    }
    
    var body: some View {
        HStack {
            
            Text("View all my Wallet")
                .font(config.fonts.semibold18)
                .padding(.leading, 16)
            
            Spacer()
            
            Image(moduleImage: "ic.arrow.left")
                .rotationEffect(.radians(.pi))
                .padding(.trailing, 6)
        }
        .padding(.horizontal, 8)
        .frame(height: 72)
        .frame(maxWidth: .infinity)
        .foregroundStyle(config.onSurfaceColor)
        .background(config.onSurfaceAlpha)
        .clipShape(RoundedRectangle(cornerRadius: config.cardRadius))
    }
}

#Preview {
    
    let config = PreviewData.paymentSheetConfig
    
    VStack {
        Spacer()
        WalletPlaceholderItem()
            .padding()
        Spacer()
    }
    .background(config.surfaceColor)
    .environmentObject(PreviewData.sessionStore)
}
