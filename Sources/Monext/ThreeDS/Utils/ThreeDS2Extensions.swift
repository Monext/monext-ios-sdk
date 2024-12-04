//
//  ThreeDS2Extensions.swift
//  Monext
//
//  Created by SDK Mobile on 16/07/2025.
//

import Foundation

extension String {
    func base64URLToBase64() -> String {
        var base64 = self
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }
        
        return base64
    }
}
