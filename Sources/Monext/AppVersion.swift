//
//  AppVersion.swift
//  Monext
//
//  Created by SDK Mobile on 15/05/2025.
//

import Foundation

struct AppVersion {
    private static func loadPlist() -> [String: Any]? {
            guard let url = Bundle.module.url(forResource: "AppMetadata", withExtension: "plist"),
                  let data = try? Data(contentsOf: url),
                  let plist = try? PropertyListSerialization
                                .propertyList(from: data, options: [], format: nil),
                  let dict = plist as? [String: Any] else {
                return nil
            }
            return dict
        }

        public static var marketingVersion: String {
            loadPlist()?["CFBundleShortVersionString"] as? String ?? "Unknown"
        }

        public static var buildNumber: String {
            loadPlist()?["CFBundleVersion"] as? String ?? ""
        }

        public static var fullVersion: String {
            guard !buildNumber.isEmpty else {
                    return "v\(marketingVersion)"
                }
                return "v\(marketingVersion) (\(buildNumber))"
        }

    static func isNewerThan(version: String) -> Bool {
        marketingVersion.compare(version, options: .numeric) == .orderedDescending
    }
}

