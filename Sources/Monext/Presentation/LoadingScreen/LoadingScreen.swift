//
//  LoadingScreen.swift
//  Monext
//
//  Created by Joshua Pierce on 27/11/2024.
//

import SwiftUI

struct LoadingScreen: View {
    
    @EnvironmentObject
    var sessionStore: SessionStateStore
    
    var body: some View {
        ZStack {
            AnimatedProgressView()
                .foregroundStyle(sessionStore.appearance.onHeaderBackgroundColor)
                .padding()
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(sessionStore.appearance.headerBackgroundColor)
    }
}


#Preview {
    VStack {
        Spacer()
        LoadingScreen()
    }
    .environmentObject(PreviewData.sessionStore)
}
