//
//  RedirectionScreen.swift
//  Monext
//
//  Created by Joshua Pierce on 26/11/2024.
//

import SwiftUI

struct RedirectionScreen: View {
    
    let onComplete: () -> Void
    
    @EnvironmentObject var sessionStore: SessionStateStore
    
    private var redirectionData: RedirectionData? {
        sessionStore.sessionState?.paymentRedirectNoResponse?.redirectionData
    }
    
    var body: some View {
        if let redirectionData {
            RedirectionWebView(
                data: redirectionData,
                onComplete: onComplete
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    
    RedirectionScreen() {}
        .environmentObject(PreviewData.sessionStore)
}
