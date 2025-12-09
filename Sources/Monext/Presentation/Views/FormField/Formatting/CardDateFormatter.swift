//
//  CardDateFormatter.swift
//  Monext
//
//  Created by Joshua Pierce on 14/11/2024.
//

struct CardDateFormatter: FormFieldView<CardField>.Formatter {
    
    private static let maxLength = 4
    
    func preformattedRawValue(_ value: String) -> String {
        return String(
            value
                .restrictToNumericInput()
                .prefix(Self.maxLength)
        )
    }
    
    func format(_ value: String) -> String {
        let digits = preformattedRawValue(value)
        // chunked(in:2) -> "MM / YY"
        return digits.chunked(into: 2, separator: " / ")
    }
}
