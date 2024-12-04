//
//  MnxtSDKContext.swift
//  Monext
//
//  Created by SDK Mobile on 27/08/2025.
//

public struct MnxtSDKContext {
    let environment: MnxtEnvironment
    let config: MnxtSDKConfiguration
    let appearance: Appearance
    let applePayConfiguration: ApplePayConfiguration
    
    public init(environment: MnxtEnvironment, config: MnxtSDKConfiguration, appearance: Appearance = .init(), applePayConfiguration: ApplePayConfiguration = .init()) {
        self.environment = environment
        self.config = config
        self.appearance = appearance
        self.applePayConfiguration = applePayConfiguration
    }
}
    
