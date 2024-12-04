//
//  XCTestCase.swift
//  Monext
//
//  Created by SDK Mobile on 31/07/2025.
//
import Foundation
import XCTest

extension XCTestCase {
    func loadTestResource(named fileName: String, withExtension ext: String = "json") -> Data {
        let bundle: Bundle
        
        #if SWIFT_PACKAGE
        bundle = Bundle.module
        #else
        bundle = Bundle(for: type(of: self))
        #endif
        
        // Essayer plusieurs emplacements
        let possibleSubdirectories = [
            "API/TestResources",
            "TestResources",
            nil
        ]
        
        for subdirectory in possibleSubdirectories {
            if let url = bundle.url(forResource: fileName, withExtension: ext, subdirectory: subdirectory) {
                guard let data = try? Data(contentsOf: url) else {
                    XCTFail("Failed to load data from: \(url)")
                    return Data()
                }
                return data
            }
        }
        
        // Debug si rien n'est trouvé
        print("Bundle path: \(bundle.bundlePath)")
        XCTFail("Failed to find test resource: \(fileName).\(ext) in any location")
        return Data()
    }
    
    func loadTestJSON(named fileName: String) -> Data {
        return loadTestResource(named: fileName, withExtension: "json")
    }
}
