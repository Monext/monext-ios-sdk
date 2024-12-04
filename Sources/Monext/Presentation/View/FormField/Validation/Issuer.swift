//
//  CardNumberValidator.swift
//  Monext
//
//  Created by Joshua Pierce on 14/11/2024.
//

import Foundation

enum Issuer: String, CaseIterable {
    
    case visa
    case mastercard
    case amex
    
    var rule: any ValidationRule {
        switch self {
        case .visa:
            return VisaValidationRule()
        case .mastercard:
            return MastercardValidationRule()
        case .amex:
            return AmexValidationRule()
        }
    }
    
    /**
     CB
     MCVISA
     AMEX
     AMEX-REC BILLING
     JCB
     BCMC
     BC/MC
     MAESTRO
     DINERS_DISCOVER
     TOTALGR
     */
    private var associatedPaymentMethodIds: [String] {
        switch self {
        case .visa: return ["CB", "MCVISA"]
        case .mastercard: return ["CB", "MCVISA"]
        case .amex: return ["AMEX"]
        }
    }
    
    func correspondingPaymentMethod(_ paymentMethods: [PaymentMethodData]) -> PaymentMethodData? {
        paymentMethods
            .compactMap {
                $0.cardCode == nil ? nil : $0
            }
            .first {
                associatedPaymentMethodIds.contains($0.cardCode!)
            }
    }
    
    static func lookupIssuer(_ cardNumber: String) -> Issuer? {
        for issuer in Issuer.allCases {
            if issuer.rule.matches(cardNumber) {
                return issuer
            }
        }
        return nil
    }
    
    static func lookupIssuer(_ wallet: Wallet) -> Issuer? {
        for issuer in Issuer.allCases {
            if issuer.associatedPaymentMethodIds.contains(wallet.cardCode) {
                return issuer
            }
        }
        return nil
    }
}

//import Foundation
//
//// MARK: - Card Type Definitions
//
//struct CardType {
//    let name: String
//    let pattern: String
//    let cvvLength: Int
//    let lengths: [Int]
//}
//
//let cardTypes: [CardType] = [
//    CardType(name: "visa", pattern: "^4", cvvLength: 3, lengths: [13, 16, 19]),
//    CardType(name: "mastercard", pattern: "^(5[1-5]|2[2-7])", cvvLength: 3, lengths: [16]),
//    CardType(name: "amex", pattern: "^3[47]", cvvLength: 4, lengths: [15]),
//    CardType(name: "diners", pattern: "^3(0[0-5]|[68])", cvvLength: 3, lengths: [14, 16]),
//    CardType(name: "discover", pattern: "^6(011|5|4[4-9]|22)", cvvLength: 3, lengths: [16, 19]),
//    CardType(name: "jcb", pattern: "^35(2[89]|[3-8][0-9])", cvvLength: 3, lengths: [16, 17, 18, 19]),
//    CardType(name: "unionpay", pattern: "^62", cvvLength: 3, lengths: [16, 17, 18, 19]),
//    CardType(name: "maestro", pattern: "^(5[06789]|6)", cvvLength: 3, lengths: [12, 13, 14, 15, 16, 17, 18, 19]),
//    CardType(name: "mir", pattern: "^220[0-4]", cvvLength: 3, lengths: [16]),
//    CardType(name: "elo", pattern: "^(4011(78|79)|4312(74|77)|438935|451416|4576(31|32)|504175|506(699|7[0-7])|509(0[0-9]|[3-6][0-9]|7[0-8])|627780|636297|636368|650(4[0-9]|5[0-9]|6[0-9])|6516(5[2-9]|[6-9][0-9])|6550(0[1-9]|1[0-9]|2[0-9]|3[0-1]))", cvvLength: 3, lengths: [16]),
//    CardType(name: "hipercard", pattern: "^(38|60)", cvvLength: 3, lengths: [16, 19])
//]
//
//// MARK: - Helper Functions
//
//func matchRegex(_ text: String, with pattern: String) -> Bool {
//    let regex = try? NSRegularExpression(pattern: pattern)
//    let range = NSRange(location: 0, length: text.utf16.count)
//    return regex?.firstMatch(in: text, options: [], range: range) != nil
//}
//
//func getCardType(for number: String) -> CardType? {
//    return cardTypes.first { matchRegex(number, with: $0.pattern) }
//}

//// MARK: - Validation Functions
//
//func validateCardNumber(_ number: String) -> Bool {
//    guard let cardType = getCardType(for: number) else { return false }
//    return cardType.lengths.contains(number.count) && luhnCheck(cardNumber: number)
//}
//
//func validateCvv(_ cvv: String, for cardNumber: String) -> Bool {
//    guard let cardType = getCardType(for: cardNumber) else { return false }
//    return cvv.count == cardType.cvvLength && Int(cvv) != nil
//}
//
//func validateExpiry(month: Int, year: Int) -> Bool {
//    let calendar = Calendar.current
//    let now = calendar.dateComponents([.month, .year], from: Date())
//    
//    guard let currentYear = now.year, let currentMonth = now.month else { return false }
//    
//    if year < currentYear {
//        return false
//    } else if year == currentYear {
//        return month >= currentMonth
//    }
//    return true
//}
