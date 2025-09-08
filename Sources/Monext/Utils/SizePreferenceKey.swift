//
//  SizePreferenceKey.swift
//  Monext
//
//  Created by Joshua Pierce on 08/11/2024.
//

import SwiftUI

struct SizePreferenceKey: PreferenceKey {
    
    static let defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
