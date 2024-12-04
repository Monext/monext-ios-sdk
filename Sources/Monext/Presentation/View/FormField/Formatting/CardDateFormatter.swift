//
//  CardDateFormatter.swift
//  Monext
//
//  Created by Joshua Pierce on 14/11/2024.
//

struct CardDateFormatter: FormFieldView.Formatter {
    
    func preformattedRawValue(_ value: String) -> String {
        value.restrictToNumericInput()
    }
    
    func format(_ value: String) -> String {
        let value = preformattedRawValue(value)
        let truncated = String(value.prefix(4))
        return truncated.chunked(into: 2, separator: " / ")
    }
}
