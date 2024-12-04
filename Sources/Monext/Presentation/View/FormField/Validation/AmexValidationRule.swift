//
//  AmexValidationRule.swift
//  Monext
//
//  Created by Joshua Pierce on 02/12/2024.
//

import Foundation

struct AmexValidationRule: ValidationRule {
    
    var pattern: Regex<Substring> { /^3[47]/ }
    
    var cvvLength: Int { 4 }
    
    var validLengths: IndexSet { [15] }
}
