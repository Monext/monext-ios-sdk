//
//  TokenExpiredScreen.swift
//  Monext
//
//  Created by Joshua Pierce on 13/03/2025.
//

import SwiftUI

struct TokenExpiredScreen: View {
    
    @EnvironmentObject var sessionStore: SessionStateStore
    
    var body: some View {
        VStack {
            Text("Your payment session has expired.")
                .font(sessionStore.appearance.fonts.bold16)
                .foregroundStyle(sessionStore.appearance.onHeaderBackgroundColor)
                .padding()
        }
        .frame(maxWidth: .infinity)
        .background(sessionStore.appearance.headerBackgroundColor)
    }
}

#Preview {
    VStack {
        Spacer()
        TokenExpiredScreen()
    }
    .environmentObject(PreviewData.sessionStore)
}
