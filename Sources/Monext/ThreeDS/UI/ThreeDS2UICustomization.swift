//
//  ThreeDS2UICustomization.swift
//  Monext
//
//  Created by SDK Mobile on 16/07/2025.
//

import Foundation
import ThreeDS_SDK

struct ThreeDS2UICustomization {
    static func createUICustomization(uiConfig: Appearance) throws -> UiCustomization {
        let uiCustomization = UiCustomization()
        
        // Toolbar
        let toolbarCustomization = ToolbarCustomization()
        try toolbarCustomization.setBackgroundColor(hexColorCode: uiConfig.headerBackgroundColor.toHex() ?? "#fcfcfc")
        try toolbarCustomization.setTextColor(hexColorCode: uiConfig.onHeaderBackgroundColor.toHex() ?? "#000000")
        uiCustomization.setToolbarCustomization(toolbarCustomization: toolbarCustomization)
        
        // Labels
        let labelCustomization = LabelCustomization()
        try labelCustomization.setHeadingTextColor(hexColorCode: "#000000")
        try labelCustomization.setTextColor(hexColorCode: "#333333")
        uiCustomization.setLabelCustomization(labelCustomization: labelCustomization)
        
        // View
        let viewCustomization = ViewCustomization()
        try viewCustomization.setChallengeViewBackgroundColor(hexColorCode: uiConfig.backgroundColor.toHex() ?? "#ffffff")
        try viewCustomization.setProgressViewBackgroundColor(hexColorCode: uiConfig.backgroundColor.toHex() ?? "#ffffff")
        uiCustomization.setViewCustomization(viewCustomization: viewCustomization)
        
        // Buttons
        let submitButtonCustomization = ButtonCustomization()
        try submitButtonCustomization.setBackgroundColor(hexColorCode: uiConfig.secondaryColor.toHex()!)
        try submitButtonCustomization.setCornerRadius(cornerRadius: 20)
        try submitButtonCustomization.setTextFontSize(fontSize: 14)
        try submitButtonCustomization.setTextColor(hexColorCode: uiConfig.onSecondaryColor.toHex()!)
        uiCustomization.setButtonCustomization(buttonCustomization: submitButtonCustomization, buttonType: .SUBMIT)

        let cancelButtonCustomization = ButtonCustomization()
        try cancelButtonCustomization.setTextColor(hexColorCode: uiConfig.onSecondaryColor.toHex() ?? "#ffffff")
        try cancelButtonCustomization.setTextFontSize(fontSize: 14)
        uiCustomization.setButtonCustomization(buttonCustomization: cancelButtonCustomization, buttonType: .CANCEL)
        
        return uiCustomization
    }
}
