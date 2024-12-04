//
//  ExampleApp.swift
//  Example
//
//  Created by My Lucky Day on Nov 7, 2024.
//

import SwiftUI
import Monext

@main
struct ExampleApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentScreen()
        }
    }
    
    public static let sampleDefaultTheme: Appearance = .init(
        headerTitle: "Monext Demo",
        headerImage: Image("logo.monext")
    )
    
    public static let sampleDarkTheme: Appearance = {
        
        let primary = Color((162, 56, 255))
        let textfield = Color((170, 164, 175))
        
        return Appearance(
            
            primaryColor: primary,
            onPrimaryColor: .white,
            secondaryColor: primary,
            onSecondaryColor: .white,
            backgroundColor: Color((15, 13, 19)),
            onBackgroundColor: .white,
            surfaceColor: Color((27, 25, 31)),
            onSurfaceColor: .white,
            confirmationColor: Color((64, 207, 176)),
            onConfirmationColor: .white,
            errorColor: Color((221, 32, 37)),
            
            textfieldLabelColor: textfield,
            textfieldTextColor: .white,
            textfieldBorderColor: textfield.opacity(0.2),
            textfieldBorderSelectedColor: primary,
            textfieldBackgroundColor: textfield.opacity(0.15),
            textfieldAccessoryColor: .white.opacity(0.3),
            
            buttonRadius: 12,
            cardRadius: 12,
            textfieldRadius: 10,
            textfieldStroke: 0,
            textfieldStrokeSelected: 2,
            paymentMethodShape: .round,
            
            headerTitle: "MONEXT DARK",
            headerBackgroundColor: Color((27, 25, 31)),
            onHeaderBackgroundColor: .white
        )
    }()
}

extension Color {
    init(_ rgb: (Int, Int, Int)) {
        self.init(red: Double(rgb.0) / 255, green: Double(rgb.1) / 255, blue: Double(rgb.2) / 255)
    }
}
