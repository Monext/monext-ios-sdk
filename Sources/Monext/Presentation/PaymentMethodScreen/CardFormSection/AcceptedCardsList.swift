//
//  AcceptedCardsList.swift
//  Monext
//
//  Created by Joshua Pierce on 14/11/2024.
//

import SwiftUI

struct AcceptedCardsList: View {
    
    let paymentMethods: [PaymentMethodData]
    
    @EnvironmentObject
    var sessionStore: SessionStateStore
    
    private var config: Appearance {
        sessionStore.appearance
    }
    
    var body: some View {
        
        VStack(spacing: 10) {
            
            Text("Accepted Cards")
                .font(config.fonts.semibold14)
                .foregroundStyle(.black)
            
            GeometryReader { geo in
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(paymentMethods, id: \.self) { paymentMethod in
                            ImageResolver.imageChipForAcceptedCards(paymentMethod.cardCode)
                        }
                    }
                    .frame(minWidth: geo.size.width)
                }
            }
            .frame(height: 48)
        }
        .padding(12)
        .background(
            RoundedRectangle(
                cornerRadius: config.cardRadius
            )
            .fill(.white)
        )
    }
}

#Preview {
    VStack {
        
        Spacer()
        
        AcceptedCardsList(
            paymentMethods: PaymentMethodData.cardGroup
        )
        
        Spacer()
    }
    .padding(16)
    .background(.gray)
    .environmentObject(PreviewData.sessionStore)
}
