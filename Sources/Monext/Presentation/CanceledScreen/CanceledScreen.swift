//
//  CanceledScreen.swift
//  Monext
//
//  Created by Joshua Pierce on 13/03/2025.
//

import SwiftUI

struct CanceledScreen: View {
    
    @EnvironmentObject var sessionStore: SessionStateStore
    
    var body: some View {
        VStack {
            Text("Your payment has been canceled.")
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
        CanceledScreen()
    }
    .environmentObject(PreviewData.sessionStore)
}
