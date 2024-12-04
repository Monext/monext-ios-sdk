//
//  DisplayMode.swift
//  Monext
//
//  Created by Joshua Pierce on 10/03/2025.
//

import SwiftUI

enum DisplayMode {
    case compact
    case fullscreen
}
struct DisplayModeKey: EnvironmentKey {
    static let defaultValue: Binding<DisplayMode> = .constant(.compact)
}
extension EnvironmentValues {
    var displayMode: Binding<DisplayMode> {
        get { self[DisplayModeKey.self] }
        set { self[DisplayModeKey.self] = newValue }
    }
}
