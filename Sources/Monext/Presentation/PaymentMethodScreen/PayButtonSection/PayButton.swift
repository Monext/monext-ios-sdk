//
//  PayButton.swift
//  Monext
//
//  Created by Joshua Pierce on 29/11/2024.
//

import SwiftUI

struct PayButton: View {
    
    let amount: String?
    let method: PaymentMethod?
    let canPay: Bool
    let loading: Bool
    let onPayTapped: () -> Void
    
    @EnvironmentObject
    var sessionStore: SessionStateStore
    
    private var config: Appearance {
        sessionStore.appearance
    }
    
    var body: some View {
        
        Button(action: {
            if canPay && !loading {
                onPayTapped()
            }
        }) {
            
            ZStack {
                if loading {
                    AnimatedProgressView()
                        .foregroundStyle(config.onSecondaryColor)
                        .frame(width: 24, height: 24)
                } else {
                    if let method = method, let title = method.data?.logo?.title {
                        Text(method.data?.form?.buttonText ?? "Continue to \(title)")
                            .font(config.fonts.bold18)
                    } else {
                        Text("Pay \(amount ?? "")")
                            .font(config.fonts.bold18)
                    }
                        
                    HStack {
                        Spacer()
                        
                        if method == nil {
                            Image(moduleImage: "ic.lock")
                                .padding(.trailing, 16)
                        }
                    }
                }
            }
            .frame(height: 48)
        }
        .foregroundStyle(config.onSecondaryColor)
        .background(
            RoundedRectangle(
                cornerRadius: config.buttonRadius
            )
            .fill()
            .foregroundStyle(config.secondaryColor)
            .opacity(canPay ? 1 : 0.3)
        )
    }
}
