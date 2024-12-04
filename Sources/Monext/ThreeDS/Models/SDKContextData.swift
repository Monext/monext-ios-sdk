//
//  SDKContextData.swift
//  Monext
//
//  Created by SDK Mobile on 16/07/2025.
//

import Foundation

/// Données de contexte du SDK envoyées lors du paiement sécurisé pour la vérification 3DS.
///
/// Cette structure contient les informations du device et les paramètres de transaction
/// requis par le protocole EMVCo 3-D Secure
struct SDKContextData: Encodable, Equatable {
    let deviceRenderingOptionsIF: String
    let deviceRenderOptionsUI: String
    let maxTimeout: Int
    let referenceNumber: String
    let ephemPubKey: String
    let appID: String
    let transID: String
    let encData: String
    
    enum CodingKeys: String, CodingKey {
        case deviceRenderingOptionsIF = "deviceRenderingOptionsIF"
        case deviceRenderOptionsUI = "deviceRenderOptionsUI"
        case maxTimeout = "maxTimeout"
        case referenceNumber = "referenceNumber"
        case ephemPubKey = "ephemPubKey"
        case appID = "appID"
        case transID = "transID"
        case encData = "encData"
    }
}
