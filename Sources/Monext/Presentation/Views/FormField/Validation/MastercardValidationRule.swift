//
//  MastercardValidationRule.swift
//  Monext
//
//  Created by Joshua Pierce on 22/11/2024.
//

import Foundation

struct MastercardValidationRule: ValidationRule {
    
    var pattern: Regex<Substring> { /^5[1-5]|^2[2-7]/ }
    
    var cvvLength: Int { 3 }
    
    var validLengths: IndexSet { [16] }
}
