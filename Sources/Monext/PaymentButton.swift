//
//  PaymentButton.swift
//  Monext
//
//  Created by Joshua Pierce on 08/11/2024.
//

import SwiftUI

/**
 This view handles payment sheet presentation upon user interaction.
 Show it in your app when the payment session token as been created and the user is ready to begin the payment process.
 */
public struct PaymentButton<Content: View>: View {
    
    private let sessionToken: String?
    private let context: MnxtSDKContext
    private let onResult: (PaymentSheetResult) -> Void
    
    /// The custom content view that will be shown inside of the button.
    public let content: Content
    
    @State private var isPresented: Bool = false
    
    /**
     - Parameters:
        - sessionToken: The `sessionId` returned when creating a new session via the Monext Retail API
        - context: The ``MnxtSDKContext`` that the SDK Configuration
        - content: The content view of the PaymentButton.
        - onResult: Closure used to inform your app that the payment transaction has terminated. See ``PaymentSheetResult`` for possible values
     */
    public init(sessionToken: String?, context: MnxtSDKContext, content: @escaping () -> Content, onResult: @escaping (PaymentSheetResult) -> Void) {
        self.sessionToken = sessionToken
        self.context = context
        self.content = content()
        self.onResult = onResult
        
        self.isPresented = isPresented
    }
    
    public var body: some View {
        Button(action: {
            if sessionToken != nil {
                isPresented = true
            }
        }) {
            content
        }
        .presentPaymentSheet(
            isPresented: $isPresented,
            sessionToken: sessionToken ?? "",
            context: context,
            onResult: onResult
        )
    }
}
