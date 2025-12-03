//
//  FailureScreen.swift
//  Monext
//
//  Created by Joshua Pierce on 26/11/2024.
//

import SwiftUI

struct FailureScreen: View {
    
    let onExit: () -> Void
    
    @EnvironmentObject var sessionStore: SessionStateStore
    
    private var config: Appearance {
        sessionStore.appearance
    }
    
    private var amount: String {
        sessionStore.sessionState?.info?.formattedAmount ?? ""
    }
    
    private var popImageStyle: PopImageView.Style {
        if let custom = config.failureImage {
            return .custom(custom)
        }
        return .failure
    }
    
    private var failureMessage: String? {
        sessionStore.sessionState?.paymentFailure?.message.localizedMessage ?? "Unknown error"
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            VStack(spacing: 16) {
                
                PopImageView(style: popImageStyle)
                
                Text("We are sorry")
                    .font(config.fonts.bold24)
                    .foregroundStyle(config.onBackgroundColor)
                
                Text("Your bank refused the payment of \(amount).")
                    .font(config.fonts.bold18)
                    .foregroundStyle(config.onBackgroundColor)
                
                Text("Please change your payment method.")
                    .font(config.fonts.bold18)
                    .foregroundStyle(config.onBackgroundColor)
                
                Spacer()
            }
            .padding(16)
            .foregroundStyle(config.onBackgroundColor)
            .background(config.backgroundColor)
            
            VStack(spacing: 10) {
                
                Button(action: { onExit() }) {
                    Text(LocalizedStringKey(config.backButtonText ?? "Back to the app"))
                        .font(config.fonts.bold18)
                        .foregroundStyle(config.onSurfaceColor)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                }
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: config.buttonRadius)
                        .stroke(config.secondaryColor)
                )
                
                // TODO: Retry action
//                Button(action: { }) {
//                    Text("Retry")
//                        .font(config.fonts.bold18)
//                        .foregroundStyle(config.onSecondaryColor)
//                        .padding(.vertical, 10)
//                }
//                .frame(maxWidth: .infinity)
//                .background(
//                    RoundedRectangle(
//                        cornerRadius: config.buttonRadius
//                    )
//                    .fill(config.secondaryColor)
//                )
            }
            .padding(16)
            .background(config.surfaceColor)
        }
    }
}

#Preview {
    FailureScreen() {}
        .environmentObject(PreviewData.sessionStore)
}
