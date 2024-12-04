//
//  GetSizeModifier.swift
//  Monext
//
//  Created by Joshua Pierce on 08/11/2024.
//

import SwiftUI

@MainActor
struct GetSizeModifier: ViewModifier {
    
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        content.overlay(
            GeometryReader { geo in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geo.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self) { newSize in
//            print("onChange -> \(newSize)")
            MainActor.assumeIsolated {
                size = newSize
            }
        }
    }
}
