//
//  ThreeDS2Models.swift
//  Monext
//
//  Created by SDK Mobile on 16/07/2025.
//

import Foundation
import ThreeDS_SDK

struct RemoteScheme: Decodable {
    let scheme: String
    let rid: String
    let publicKey: String
    var rootPublicKey: String
    
    init(scheme: String, rid: String, publicKey: String, rootPublicKey: String) {
        self.scheme = scheme
        self.rid = rid
        self.publicKey = publicKey
        self.rootPublicKey = rootPublicKey
    }
}

struct DirectoryServerSdkKeyListResponse: Decodable {
    let directoryServerSdkKeyList: [RemoteScheme]
}

struct SchemeData {
    let name: String
    let rid: String
    let scheme: Scheme
}

struct AuthenticationResponse: Codable, Equatable {
    let acsReferenceNumber: String
    let acsTransID: String?
    let threeDSVersion: String
    let threeDSServerTransID: String
    let transStatus: String?
}

extension ThreeDS2Error {
    @objc public static func InvalidData(message: String, cause: (any Error)? = nil) -> any Error {
        return NSError(
            domain: "com.monext.ThreeDS2",
            code: 1002,
            userInfo: [
                NSLocalizedDescriptionKey: message,
                NSUnderlyingErrorKey: cause as Any
            ]
        )
    }
}

enum SchemeError: Error, Equatable {
    case unsupportedCardCode(String)
}
