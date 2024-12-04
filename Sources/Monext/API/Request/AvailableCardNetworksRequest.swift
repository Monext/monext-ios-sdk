//
//  AvailableCardNetworksRequest.swift
//  Monext
//
//  Created by Joshua Pierce on 08/11/2024.
//

struct AvailableCardNetworksRequest: Encodable {
    let cardNumber: String
    let handledContracts: [HandledContract]
}

struct HandledContract: Encodable {
    let cardCode: String
    let contractNumber: String
}
