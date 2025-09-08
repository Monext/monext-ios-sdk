//
//  VisaValidationRule.swift
//  Monext
//
//  Created by Joshua Pierce on 22/11/2024.
//

import Foundation

struct VisaValidationRule: ValidationRule {
    
    var pattern: Regex<Substring> { /^4/ }
    
    var cvvLength: Int { 3 }
    
    var validLengths: IndexSet { [13, 16, 19] }
}
