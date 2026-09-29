//
//  SecurityCheck.swift
//  Monext
//
//  Created by lucas bianciotto  on 29/09/2026.
//

protocol SecurityCheck: Sendable {
    func check() -> Bool
}
