//
//  MnxtSDKConfiguration.swift
//  Monext
//
//  Created by SDK Mobile on 27/08/2025.
//

public struct MnxtSDKConfiguration: Sendable {
    let language: String?
    
    public init(language: String? = nil) {
        self.language = language
    }
}
