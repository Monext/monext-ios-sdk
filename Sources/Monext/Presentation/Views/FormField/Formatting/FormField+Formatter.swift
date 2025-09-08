//
//  FormField+Formatter.swift
//  Monext
//
//  Created by Joshua Pierce on 14/11/2024.
//

extension FormFieldView {
    
    protocol Formatter {
        func preformattedRawValue(_ value: String) -> String
        func format(_ value: String) -> String
    }
}
