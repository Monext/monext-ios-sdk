//
//  CompliancyNotice.swift
//  Monext
//
//  Created by Joshua Pierce on 28/11/2024.
//

import SwiftUI

struct CompliancyNotice: View {
    
    @EnvironmentObject
    var sessionStore: SessionStateStore
    
    private var config: Appearance {
        sessionStore.appearance
    }
    
    var body: some View {
        
        HStack(spacing: 10) {
            
            ZStack {
                
                Image(moduleImage: "ic.shield.filled")
                    .foregroundStyle(config.confirmationColor)
                
                Image(moduleImage: "ic.check.small")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            
            Text("We are fully compliant with the payment card industry data security standards.")
                .font(config.fonts.semibold12)
            
            Spacer()
        }
        .padding(12)
        .foregroundStyle(config.onConfirmationColor)
        .background(
            RoundedRectangle(
                cornerRadius: config.cardRadius
            )
            .fill(config.confirmationAlpha)
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: config.cardRadius
            )
            .inset(by: 1)
            .stroke(config.confirmationAlpha, lineWidth: 2)
        )
    }
}

#Preview {
    VStack {
        CompliancyNotice()
            .padding()
    }
    .environmentObject(PreviewData.sessionStore)
}
