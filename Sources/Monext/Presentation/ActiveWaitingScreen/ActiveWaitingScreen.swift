//
//  LoadingScreen.swift
//  Monext
//
//  Created by Joshua Pierce on 27/11/2024.
//

import SwiftUI

struct ActiveWaitingScreen: View {
    
    @EnvironmentObject
    var sessionStore: SessionStateStore
    
    private var appearance: Appearance {
        sessionStore.appearance
    }
    
    private var localizedHTML: String? {
        sessionStore.sessionState?.activeWaiting?.message?.localizedMessage
    }
    
    private var displayMessage: DisplayMessage {
        guard let html = localizedHTML, !html.isEmpty else {
            return .fallback
        }
        
        let nodes = RichHTMLMessageParser().parse(html)
        let builder = RichAttributedBuilder(
            baseFont: appearance.fonts.semibold14,
            baseColor: appearance.onBackgroundColor,
            linkColor: appearance.secondaryColor,
            underlineLinks: true,
            addSoftWrapForLongWords: true
        )
        let attributedMessage = builder.build(from: nodes)
        return .attributed(attributedMessage)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            AnimatedProgressView()
                .foregroundStyle(appearance.onHeaderBackgroundColor)
                .frame(width: 44, height: 44)
            
            Text("Awaiting validation")
                .font(appearance.fonts.semibold20)
                .foregroundColor(appearance.onHeaderBackgroundColor)
                .multilineTextAlignment(.center)
            
            messageContent
        }
        .frame(height: 180)
        .padding()
        .frame(maxWidth: .infinity)
        .background(appearance.headerBackgroundColor)
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var messageContent: some View {
        switch displayMessage {
        case .attributed(let attributedMessage):
            Text(attributedMessage)
                .font(appearance.fonts.semibold14)
                .foregroundStyle(appearance.onBackgroundColor)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        case .fallback:
            EmptyView()
        }
}

// MARK: - Supporting Types

private enum DisplayMessage {
    case attributed(AttributedString)
    case fallback
}
    
    
}

#Preview {
    VStack {
        Spacer()
        ActiveWaitingScreen()
    }
    .environmentObject(PreviewData.sessionStore)
}
