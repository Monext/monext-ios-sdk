//
//  ValidationRule.swift
//  Monext
//
//  Created by Joshua Pierce on 22/11/2024.
//

import Foundation

protocol ValidationRule {
    var pattern: Regex<Substring> { get }
    var validLengths: IndexSet { get }
    var cvvLength: Int { get }
    func matches(_ cardNumber: String) -> Bool
    func isValidCvv(_ cvv: String) -> Bool
    func isValidCardNumber(_ cardNumber: String) -> Bool
}

extension ValidationRule {
    
    var cvvMinLength: Int { 3 }
    
    func matches(_ cardNumber: String) -> Bool {
        cardNumber.firstMatch(of: pattern) != nil
    }
    
    func isValidCvv(_ cvv: String) -> Bool {
        cvv.unicodeScalars.count == cvvLength
    }
    
    func isValidCardNumber(_ cardNumber: String) -> Bool {
        guard matches(cardNumber) else { return false }
        return validLengths.contains(cardNumber.count) && cardNumber.passesLuhnCheck()
    }
}

extension DateFormatter {
    
    static func isValidCardExpiration(_ cardExpiration: String) -> Bool {
        
        let validator: (Date) -> Bool = { expiration in
            
            var dateComps = Calendar.current.dateComponents([.year, .month], from: expiration)
            dateComps.calendar = Calendar.current
            let testDate = (dateComps.date ?? Date.distantPast)
            
            var nowComps = Calendar.current.dateComponents([.year, .month], from: Date.now)
            nowComps.calendar = Calendar.current
            let nowDate = (nowComps.date ?? .now)
            
            return !(testDate < nowDate)
        }
        
        guard let date = DateFormatter.cardNetworkFormat.date(from: cardExpiration) else {
            return false
        }
        
        return validator(date)
    }
}
