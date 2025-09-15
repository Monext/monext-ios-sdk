//
//  CardCvvFormatter.swift
//  Monext
//
//  Created by Joshua Pierce on 14/11/2024.
//

struct CardCvvFormatter: FormFieldView<CardField>.Formatter {
    
    func preformattedRawValue(_ value: String) -> String {
        value.restrictToNumericInput()
    }
    
    func format(_ value: String) -> String {
        String(value.prefix(4))
    }
}
