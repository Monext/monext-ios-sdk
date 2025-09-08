//
//  Logger+Monext.swift
//  Monext
//
//  Created by Joshua Pierce on 12/11/2024.
//

import OSLog

extension Logger {
    
    private static let subsystem = Bundle.module.bundleIdentifier!
    
    static let network = Logger(subsystem: subsystem, category: "network")
}
