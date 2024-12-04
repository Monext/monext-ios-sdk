//
//  DeviceDataTransformer.swift
//  Monext
//
//  Created by SDK Mobile on 16/07/2025.
//

import Foundation
import ThreeDS_SDK

struct DeviceDataTransformer {
    static func transformDeviceData(_ deviceData: String) throws -> String {
        guard let jsonData = deviceData.data(using: .utf8) else {
            throw ThreeDS2Error.InvalidData(message: "Impossible de convertir deviceData en Data")
        }
        
        guard let jwk = try? JSONSerialization.jsonObject(with: jsonData) as? [String: String] else {
            throw ThreeDS2Error.InvalidData(message: "Format JSON invalide")
        }
        
        guard let kty = jwk["kty"],
              let crv = jwk["crv"],
              let xCoord = jwk["x"],
              let yCoord = jwk["y"] else {
            throw ThreeDS2Error.InvalidData(message: "Clés JWK manquantes (kty, crv, x, y)")
        }
        
        guard kty == "EC" && crv == "P-256" else {
            throw ThreeDS2Error.InvalidData(message: "Type de clé non supporté: \(kty) \(crv)")
        }
        
        let xBase64 = xCoord.base64URLToBase64()
        let yBase64 = yCoord.base64URLToBase64()
        
        guard let xData = Data(base64Encoded: xBase64),
              let yData = Data(base64Encoded: yBase64) else {
            throw ThreeDS2Error.InvalidData(message: "Impossible de décoder les coordonnées base64")
        }
        
        let xFinal = xData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        
        let yFinal = yData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        
        return "\(crv);\(kty);\(xFinal);\(yFinal)"
    }
}
