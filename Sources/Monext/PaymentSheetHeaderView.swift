//
//  PaymentSheetHeaderView.swift
//  Monext
//
//  Created by Joshua Pierce on 12/11/2024.
//

import SwiftUI

struct PaymentSheetHeaderView: View {
    
    @Binding var isPresented: Bool
    
    @State private var isPresentedExitDialog = false
    
    @EnvironmentObject var sessionStore: SessionStateStore
    
    var body: some View {
        
        ZStack(alignment: .leading) {

            Button(action: exitPaymentSheet) {
                Image(moduleImage: "ic.x")
                    .frame(width: 40, height: 40)
            }
            .padding(.leading, 16)
            .modifier(
                ExitPaymentDialog(
                    isPresented: $isPresentedExitDialog,
                    onExit: { isPresented = false }
                )
            )
            
            HStack {
                
                Spacer()
                
                if let shopImage = sessionStore.appearance.headerImage {
                    shopImage
                } else if let shopName = sessionStore.appearance.headerTitle {
                    Text(shopName)
                        .font(sessionStore.appearance.fonts.bold18)
                }
                
                Spacer()
            }
        }
        .frame(height: 64)
        .foregroundStyle(sessionStore.appearance.onHeaderBackgroundColor)
        .background(sessionStore.appearance.headerBackgroundColor)
    }
    
    private func exitPaymentSheet() {
        switch sessionStore.sessionState?.type {
        case SessionType.paymentMethods.rawValue, SessionType.redirection.rawValue:
            isPresentedExitDialog = true
        default:
            isPresented = false
        }
    }
}

#Preview {
    PaymentSheetHeaderView(isPresented: .constant(true))
        .background(Color(white: 0.8))
        .environmentObject(PreviewData.sessionStore)
}
