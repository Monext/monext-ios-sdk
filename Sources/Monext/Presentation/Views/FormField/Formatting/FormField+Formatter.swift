//
//  FormField+Formatter.swift
//  Monext
//
//  Created by Joshua Pierce on 14/11/2024.
//

public protocol FormFieldFormatter {
    func preformattedRawValue(_ value: String) -> String
    func format(_ value: String) -> String
}

//Alias dans la struct pour la compatibilité :
extension FormFieldView {
    typealias Formatter = FormFieldFormatter
}
