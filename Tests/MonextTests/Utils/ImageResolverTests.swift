//
//  ImageResolverTests.swift
//  Monext
//
//  Created by SDK Mobile on 09/07/2025.
//
import XCTest
import SwiftUI
import ViewInspector

@testable import Monext

@MainActor
final class ImageResolverTests: XCTestCase {
    func testImageChipForCardsShowsCardImageAndText() throws {
        let method = PaymentMethod.cards([
            .init(
                cardCode: "CB",
                contractNumber: "CB_FAKE",
                disabled: false,
                hasForm: false,
                form: nil,
                hasLogo: false,
                logo: nil,
                isIsolated: false,
                options: [ "EXPI_DATE", "CVV", "ALT_NETWORK", "HOLDER" ],
                paymentMethodAction: 0,
                additionalData: .init(
                    merchantCapabilities: nil,
                    networks: nil,
                    applePayMerchantId: nil,
                    applePayMerchantName: nil
                ),
                shouldBeInTopPosition: false,
                state: "AVAILABLE"
            )
        ])
        
        let view = ImageResolver.imageChipForPaymentMethod(method)
        
        let text = try view.inspect().find(text: "Card")
        XCTAssertEqual(try text.string(), "Card")
        
        let image = try view.inspect().find(ViewType.Image.self)
        XCTAssertEqual(try image.actualImage().name(), "ic.creditcards")
    }
    
    func testImageChipForAlternativePaymentMethodsImage() throws {
        let method: PaymentMethod = .alternativePaymentMethod(
            .init(
                cardCode: "IDEAL_MNXT",
                contractNumber: "IDEAL_MNXT",
                disabled: false,
                hasForm: true,
                form: PaymentMethodForm(
                    displayButton: true,
                    description: "By choosing this payment method, you select your bank, then validate your payment. There's no need to register - your bank account is all you need to pay.",
                    buttonText: "Continue to iDeal"
                ),
                hasLogo: true,
                logo: PaymentMethodLogo(
                    width: 45,
                    height: 30,
                    url: "https://webpayment.dev.payline.com/HMI/payline-widget/pmapiresources/logo/IDEAL_MNXT/3.2-SNAPSHOT",
                    alt: "Ideal logo",
                    title: "Ideal"
                ),
                isIsolated: false,
                options: [],
                paymentMethodAction: 0,
                additionalData: AdditionalData(),
                shouldBeInTopPosition: false,
                state: "AVAILABLE"
            )
        )
        
        let view = ImageResolver.imageChipForPaymentMethod(method)
        
        let asyncImage = try view.inspect().find(ViewType.AsyncImage.self)
        let url = try asyncImage.url()
        XCTAssertEqual(url?.absoluteString, method.data?.logo?.url)
    }
    
    func testImageChipForAlternativePaymentMethodsImageWhenNoLogo() throws {
        let method: PaymentMethod = .alternativePaymentMethod(
            .init(
                cardCode: "IDEAL_MNXT",
                contractNumber: "IDEAL_MNXT",
                disabled: false,
                hasForm: true,
                form: PaymentMethodForm(
                    displayButton: true,
                    description: "By choosing this payment method, you select your bank, then validate your payment. There's no need to register - your bank account is all you need to pay.",
                    buttonText: "Continue to iDeal"
                ),
                hasLogo: true,
                logo: PaymentMethodLogo(
                    width: 45,
                    height: 30,
                    url: "",
                    alt: "Ideal logo",
                    title: "Ideal"
                ),
                isIsolated: false,
                options: [],
                paymentMethodAction: 0,
                additionalData: AdditionalData(),
                shouldBeInTopPosition: false,
                state: "AVAILABLE"
            )
        )
        
        let view = ImageResolver.imageChipForPaymentMethod(method)
        
        let text = try view.inspect().find(text: "Ideal")
        XCTAssertEqual(try text.string(), "Ideal")
    }
        
}
