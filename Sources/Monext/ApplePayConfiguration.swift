//
//  ApplePayConfiguration.swift
//  Monext
//
//  Created by Joshua Pierce on 02/12/2024.
//

import PassKit
import SwiftUI

/**
 Used to configure the visual attributes of the `PayWithApplePayButton`.
 */
public struct ApplePayConfiguration {
    
    let buttonLabel: PayWithApplePayButtonLabel
    let buttonStyle: PayWithApplePayButtonStyle
    
    /**
     - Parameters:
        - buttonLabel: `PayWithApplePayButtonLabel` see [official docs](https://developer.apple.com/documentation/passkit/paywithapplepaybuttonlabel) for details
        - buttonStyle: `PayWithApplePayButtonStyle` see [official docs](https://developer.apple.com/documentation/passkit/paywithapplepaybuttonstyle) for details
     */
    public init(buttonLabel: PayWithApplePayButtonLabel = .plain, buttonStyle: PayWithApplePayButtonStyle = .black) {
        self.buttonLabel = buttonLabel
        self.buttonStyle = buttonStyle
    }
}
