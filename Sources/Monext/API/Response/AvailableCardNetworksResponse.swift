//
//  AvailableCardNetworksResponse.swift
//  Monext
//
//  Created by Joshua Pierce on 08/11/2024.
//

struct AvailableCardNetworksResponse: Decodable {
    
    let alternativeNetwork: String?
    let alternativeNetworkCode: String?
    let defaultNetwork: String?
    let defaultNetworkCode: String?
    let selectedContractNumber: String?
    
    var defaultCardNetwork: CardNetwork? {
        guard let defaultNetwork, let defaultNetworkCode else { return nil }
        return .init(network: defaultNetwork, code: defaultNetworkCode)
    }
    
    var altCardNetwork: CardNetwork? {
        guard let alternativeNetwork, let alternativeNetworkCode else { return nil }
        return .init(network: alternativeNetwork, code: alternativeNetworkCode)
    }
}
