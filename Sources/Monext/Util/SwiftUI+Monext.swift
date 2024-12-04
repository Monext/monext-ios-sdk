//
//  View+Monext.swift
//  Monext
//
//  Created by Joshua Pierce on 08/11/2024.
//

import SwiftUI

public extension View {
    
    /**
     Used to present the payment sheet. The preferred method to integrate the payment process in an application is with ``PaymentButton``.
     Use this method if you need more extensive customization than ``PaymentButton`` provides.
     */
    func presentPaymentSheet(isPresented: Binding<Bool>, sessionToken: String, context: MnxtSDKContext, onResult: @escaping (PaymentSheetResult) -> Void) -> some View {
        return ModifiedContent(
            content: self,
            modifier: PaymentSheetPresenter(
                isPresented: isPresented,
                sessionToken: sessionToken,
                sessionStateStore: .init(environment: context.environment, appearance: context.appearance, config: context.config, applePayConfiguration: context.applePayConfiguration),
                onResult: onResult
            )
        )
    }
    
    internal func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> V { block(self) }
}

extension Image {
    
    init(moduleImage: String) {
        self.init(moduleImage, bundle: .module)
    }
}

extension Color {
    
    init(_ rgb: (Int, Int, Int)) {
        self.init(red: Double(rgb.0) / 255, green: Double(rgb.1) / 255, blue: Double(rgb.2) / 255)
    }
}

extension Text {
    init(_ key: LocalizedStringKey, comment: String = "") {
        self.init(key, bundle: .module)
    }
}

extension Button  where Label == Text {
    init(_ titleKey: LocalizedStringKey, action: @escaping () -> Void) {
        self.init(action: action) {
            Text(titleKey, bundle: .module)
        }
    }
}
