//
//  SuccessScreen.swift
//  Monext
//
//  Created by Joshua Pierce on 26/11/2024.
//

import SwiftUI

struct SuccessScreen: View {
    
    let onExit: () -> Void
    
    @EnvironmentObject var sessionStore: SessionStateStore
    
    private var config: Appearance {
        sessionStore.appearance
    }
    
    var successData: PaymentSuccess? {
        sessionStore.sessionState?.paymentSuccess
    }
    
    var tickets: [Ticket] {
        successData?.ticket ?? []
    }
    
    var amount: String {
        sessionStore.sessionState?.info?.formattedAmount ?? ""
    }
    
    var orderRef: String {
        sessionStore.sessionState?.info?.orderRef ?? ""
    }
    
    var popImageStyle: PopImageView.Style {
        if let custom = config.successImage {
            return .custom(custom)
        }
        return .success
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            ScrollView {
                
                VStack(alignment: .center, spacing: 16) {
                    
                    PopImageView(style: popImageStyle)
                    
                    Text("Congratulations")
                        .font(config.fonts.bold24)
                        .foregroundStyle(config.onBackgroundColor)
                    
                    Text("Your payment of \(amount) has been received. Your order \(orderRef) is confirmed. Thank you for your order!")
                        .font(config.fonts.bold18)
                        .foregroundStyle(config.onBackgroundColor)
                    
                    VStack(spacing: 8) {
                        ForEach(tickets, id: \.self) { ticket in
                            HStack {
                                Text(ticket.key ?? "")
                                Spacer()
                                Text(ticket.value)
                            }
                            .font(config.fonts.semibold12)
                            .foregroundStyle(config.onBackgroundColor)
                        }
                    }
                }
                .padding(16)
            }
            .background(config.backgroundColor)
            
            Button(action: { onExit() }) {
                Text(LocalizedStringKey(config.backButtonText ?? "Back to the app"))
                    .font(config.fonts.bold18)
                    .padding(.vertical, 10)
                    .foregroundStyle(config.onSecondaryColor)
                    .frame(maxWidth: .infinity)
            }
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: config.buttonRadius)
                    .fill(config.secondaryColor)
            )
            .padding(16)
            .background(config.surfaceColor)
            
        }
    }
}

#Preview {
    SuccessScreen() {}
        .environmentObject(PreviewData.sessionStore)
}
