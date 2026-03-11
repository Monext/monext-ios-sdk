//
//  DisableCardArtIfAvailable.swift
//  Monext
//
//  Created by lucas bianciotto  on 11/03/2026.
//

import SwiftUI

/// A `ViewModifier` that disables the card art display on the Apple Pay button
/// introduced in iOS 26.
///
/// On earlier iOS versions, this modifier has no effect.
///
/// ## Usage
/// ```swift
/// PayWithApplePayButton(...)
///     .modifier(DisableCardArtIfAvailable())
/// ```
struct DisableCardArtIfAvailable: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            AnyView(content.payWithApplePayButtonDisableCardArt())
        } else {
            AnyView(content)
        }
    }
}
