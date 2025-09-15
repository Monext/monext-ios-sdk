//
//  CardNumberFormatter.swift
//  Monext
//
//  Created by Joshua Pierce on 14/11/2024.
//

struct CardNumberFormatter: FormFieldView<CardField>.Formatter {
    
    private static let maxLength: Int = 19
    
    func preformattedRawValue(_ value: String) -> String {
//        var scalers = value.unicodeScalars
//        scalers.removeAll(where: CharacterSet.decimalDigits.inverted.contains)
//        return String(scalers)
        String(
            value
                .restrictToNumericInput()
                .prefix(Self.maxLength)
        )
    }
    
    func format(_ value: String) -> String {
        let value = preformattedRawValue(value)
        return value.chunked(into: 4)
    }
}
