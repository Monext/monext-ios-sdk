//
//  MockProgressDialog.swift
//  Monext
//
//  Created by SDK Mobile on 24/07/2025.
//

import Foundation
import ThreeDS_SDK

class MockProgressDialog: NSObject, ProgressDialog {
    var didStart = false
    var didStop = false

    func start() {
        didStart = true
        // Simule le démarrage du dialogue de progression
    }

    func stop() {
        didStop = true
        // Simule l'arrêt du dialogue de progression
    }
}
