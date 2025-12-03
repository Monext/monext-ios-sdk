//
//  PaymentSheetConfiguration.swift
//  Monext
//
//  Created by Joshua Pierce on 12/11/2024.
//

import SwiftUI
import Combine

/**
 
 ## Discussion
 
 Used to configure the visual elements of the payment sheet.
 
 All available UI customizations are contained in this class. You are not required to modify any element, the default is a black-and-white light theme.
 It is recommended to provide the ``PaymentSheetConfiguration/headerTitle`` or ``PaymentSheetConfiguration/headerImage`` at a minimum in order to identify your brand.
 
 > Note: UI customizations are extensively documented with examples [here](https://www.figma.com).
 
 ### Header
 
 - ``headerTitle``
 - ``headerImage``
 - ``headerBackgroundColor``
 - ``onHeaderBackgroundColor``
 
 ### Colors
 
 - ``primaryColor``
 - ``onPrimaryColor``
 - ``secondaryColor``
 - ``onSecondaryColor``
 - ``backgroundColor``
 - ``onBackgroundColor``
 - ``surfaceColor``
 - ``onSurfaceColor``
 - ``confirmationColor``
 - ``onConfirmationColor``
 - ``errorColor``
 
 ### Textfield
 
 - ``textfieldLabelColor``
 - ``textfieldTextColor``
 - ``textfieldBorderColor``
 - ``textfieldBorderSelectedColor``
 - ``textfieldBackgroundColor``
 - ``textfieldAccessoryColor``
 
 ### Dimensions
 
 - ``buttonRadius``
 - ``cardRadius``
 - ``textfieldRadius``
 - ``textfieldStroke``
 - ``textfieldStrokeSelected``
 - ``paymentMethodShape-swift.property``
 
 ### Result
 
 - ``successImage``
 - ``failureImage``
 */
public final class Appearance: Sendable {
    
    // MARK: - Public properties -
    
    // MARK: Colors
    
    public let primaryColor: Color
    public let onPrimaryColor: Color
    public let secondaryColor: Color
    public let onSecondaryColor: Color
    public let backgroundColor: Color
    public let onBackgroundColor: Color
    public let surfaceColor: Color
    public let onSurfaceColor: Color
    public let confirmationColor: Color
    public let onConfirmationColor: Color
    public let errorColor: Color
    
    // MARK: Textfield
    
    public let textfieldLabelColor: Color
    public let textfieldTextColor: Color
    public let textfieldBorderColor: Color
    public let textfieldBorderSelectedColor: Color
    public let textfieldBackgroundColor: Color
    public let textfieldAccessoryColor: Color
    
    // MARK: Dimensions
    
    public let buttonRadius: CGFloat
    public let cardRadius: CGFloat
    public let textfieldRadius: CGFloat
    public let textfieldStroke: CGFloat
    public let textfieldStrokeSelected: CGFloat
    public let paymentMethodShape: PaymentMethodShape
    
    // MARK: Header
    
    public let headerTitle: String?
    public let headerImage: Image?
    public let headerBackgroundColor: Color
    public let onHeaderBackgroundColor: Color
    
    // MARK: Button
    public let backButtonText: String?
    
    // MARK: Result
    
    /// The image shown to the user on the success screen when the transaction has succeeded
    public let successImage: Image?
    
    /// The image shown to the user on the failure screen when the transaction has failed
    public let failureImage: Image?
    
    // MARK: - Derived properties
    
    let primaryAlpha: Color
    let secondaryAlpha: Color
    let confirmationAlpha: Color
    let onSurfaceAlpha: Color
    let onSurfaceCardNumber: Color
    let paymentMethodRadius: CGFloat
    let textfieldLabelOnSurfaceColor: Color
    let textfieldTextOnSurfaceColor: Color
    let textfieldBorderOnSurfaceColor: Color
    let textfieldBorderSelectedOnSurfaceColor: Color
    let textfieldBackgroundOnSurfaceColor: Color
    let textfieldAccessoryOnSurfaceColor: Color
    let onHeaderBackgroundAlpha: Color
    
    // MARK: - Fixed properties
    let fonts = DefaultFontBook()
    
    // MARK: - Init
    
    // TODO: Doc
    public init(
        primaryColor: Color = Defaults.primaryColor,
        onPrimaryColor: Color = Defaults.onPrimaryColor,
        secondaryColor: Color = Defaults.secondaryColor,
        onSecondaryColor: Color = Defaults.onSecondaryColor,
        backgroundColor: Color = Defaults.backgroundColor,
        onBackgroundColor: Color = Defaults.onBackgroundColor,
        surfaceColor: Color = Defaults.surfaceColor,
        onSurfaceColor: Color = Defaults.onSurfaceColor,
        confirmationColor: Color = Defaults.confirmationColor,
        onConfirmationColor: Color = Defaults.onConfirmationColor,
        errorColor: Color = Defaults.errorColor,
        textfieldLabelColor: Color? = nil,
        textfieldTextColor: Color? = nil,
        textfieldBorderColor: Color? = nil,
        textfieldBorderSelectedColor: Color? = nil,
        textfieldBackgroundColor: Color? = nil,
        textfieldAccessoryColor: Color? = nil,
        
        buttonRadius: CGFloat = Defaults.buttonRadius,
        cardRadius: CGFloat = Defaults.cardRadius,
        textfieldRadius: CGFloat = Defaults.textfieldRadius,
        textfieldStroke: CGFloat = Defaults.textfieldStroke,
        textfieldStrokeSelected: CGFloat = Defaults.textfieldStrokeSelected,
        paymentMethodShape: PaymentMethodShape = Defaults.paymentMethodShape,
        
        headerTitle: String? = nil,
        headerImage: Image? = nil,
        headerBackgroundColor: Color = Defaults.headerBackgroundColor,
        onHeaderBackgroundColor: Color = Defaults.onHeaderBackgroundColor,
        
        backButtonText: String? = nil,
        
        successImage: Image? = nil,
        failureImage: Image? = nil
    ) {
        self.primaryColor = primaryColor
        self.primaryAlpha = self.primaryColor.opacity(0.05)
        self.onPrimaryColor = onPrimaryColor
        self.secondaryColor = secondaryColor
        self.secondaryAlpha = secondaryColor.opacity(0.05)
        self.onSecondaryColor = onSecondaryColor
        self.backgroundColor = backgroundColor
        self.onBackgroundColor = onBackgroundColor
        self.surfaceColor = surfaceColor
        self.onSurfaceColor = onSurfaceColor
        self.onSurfaceAlpha = onSurfaceColor.opacity(0.1)
        self.onSurfaceCardNumber = onSurfaceColor.opacity(0.6)
        self.confirmationColor = confirmationColor
        self.confirmationAlpha = confirmationColor.opacity(0.05)
        self.onConfirmationColor = onConfirmationColor
        self.errorColor = errorColor
        
        self.textfieldLabelColor = textfieldLabelColor ?? onBackgroundColor
        self.textfieldTextColor = textfieldTextColor ?? onBackgroundColor
        self.textfieldBorderColor = textfieldBorderColor ?? onBackgroundColor.opacity(0.2)
        self.textfieldBorderSelectedColor = textfieldBorderSelectedColor ?? onBackgroundColor
        self.textfieldBackgroundColor = textfieldBackgroundColor ?? .clear
        self.textfieldAccessoryColor = textfieldAccessoryColor ?? onBackgroundColor.opacity(0.3)
        
        self.textfieldLabelOnSurfaceColor = textfieldLabelColor ?? onSurfaceColor
        self.textfieldTextOnSurfaceColor = textfieldTextColor ?? onSurfaceColor
        self.textfieldBorderOnSurfaceColor = textfieldBorderColor ?? onSurfaceColor.opacity(0.2)
        self.textfieldBorderSelectedOnSurfaceColor = textfieldBorderSelectedColor ?? onSurfaceColor
        self.textfieldBackgroundOnSurfaceColor = textfieldBackgroundColor ?? .clear
        self.textfieldAccessoryOnSurfaceColor = textfieldAccessoryColor ?? onSurfaceColor.opacity(0.3)
        
        self.buttonRadius = buttonRadius
        self.cardRadius = cardRadius
        self.textfieldRadius = textfieldRadius
        self.textfieldStroke = textfieldStroke
        self.textfieldStrokeSelected = textfieldStrokeSelected
        
        self.paymentMethodShape = paymentMethodShape
        switch paymentMethodShape {
        case .round: paymentMethodRadius = 10
        case .square: paymentMethodRadius = 0
        }
        
        self.headerTitle = headerTitle
        self.headerImage = headerImage
        self.headerBackgroundColor = headerBackgroundColor
        self.onHeaderBackgroundColor = onHeaderBackgroundColor
        self.onHeaderBackgroundAlpha = onHeaderBackgroundColor.opacity(0.1)
        
        self.backButtonText = backButtonText
        
        self.successImage = successImage
        self.failureImage = failureImage
    }
    
    // MARK: - Defaults
    
    /**
     Default values for required properties
     
     > Note: Internal use
     */
    public struct Defaults {
        
        struct Colors {
            static let arsenic = Color((56, 68, 75))
            static let cultured = Color((244, 245, 247))
            static let malachite = Color((0, 206, 106))
            static let alabamaCrimson = Color((172, 0, 54))
            static let radicalRed = Color((253, 47, 111))
        }
        
        public static let primaryColor: Color = Colors.arsenic
        public static let onPrimaryColor: Color = .white
        public static let secondaryColor: Color = Colors.radicalRed
        public static let onSecondaryColor: Color = .white
        public static let backgroundColor: Color = Colors.cultured
        public static let onBackgroundColor: Color = Colors.arsenic
        public static let surfaceColor: Color = .white
        public static let onSurfaceColor: Color = Colors.arsenic
        public static let confirmationColor: Color = Colors.malachite
        public static let onConfirmationColor: Color = Colors.arsenic
        public static let errorColor: Color = Colors.alabamaCrimson
        
        public static let buttonRadius: CGFloat = 24
        public static let cardRadius: CGFloat = 16
        public static let textfieldRadius: CGFloat = 10
        public static let textfieldStroke: CGFloat = 1
        public static let textfieldStrokeSelected: CGFloat = 2
        public static let paymentMethodShape: PaymentMethodShape = .round
        
        public static let headerBackgroundColor = Colors.cultured
        public static let onHeaderBackgroundColor = Colors.arsenic
    }
    
    // MARK: - Fonts
    
    struct DefaultFontBook {
        
        static let semiboldName = "AvenirNext-DemiBold"
        let semibold11 = Font.custom(semiboldName, size: 11)
        let semibold12 = Font.custom(semiboldName, size: 12)
        let semibold14 = Font.custom(semiboldName, size: 14)
        let semibold16 = Font.custom(semiboldName, size: 16)
        let semibold18 = Font.custom(semiboldName, size: 18)
        let semibold20 = Font.custom(semiboldName, size: 20)
        
        static let boldName = "AvenirNext-Bold"
        let bold14 = Font.custom(boldName, size: 14)
        let bold16 = Font.custom(boldName, size: 16)
        let bold18 = Font.custom(boldName, size: 18)
        let bold24 = Font.custom(boldName, size: 24)
        
        /*
         Avenir Next
         == AvenirNext-Regular
         == AvenirNext-Italic
         == AvenirNext-UltraLight
         == AvenirNext-UltraLightItalic
         == AvenirNext-Medium
         == AvenirNext-MediumItalic
         == AvenirNext-DemiBold
         == AvenirNext-DemiBoldItalic
         == AvenirNext-Bold
         == AvenirNext-BoldItalic
         == AvenirNext-Heavy
         == AvenirNext-HeavyItalic
         */
    }
    
    // MARK: - Enums
    
    /// Controls the shape of the payment method icons found in the SDK.
    public enum PaymentMethodShape: Sendable {
        case round
        case square
    }
}
