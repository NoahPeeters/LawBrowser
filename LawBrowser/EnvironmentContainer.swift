//
//  EnvironmentContainer.swift
//  LawBrowser
//
//  Created by Noah Peeters on 01.06.20.
//  Copyright © 2020 Noah Peeters. All rights reserved.
//

import Foundation
import LawClient
import LawModel

class EnvironmentContainer {
    let apiClient: LawClient

    init() {
        // swiftlint:disable force_unwrapping
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let baseURL = URL(string: "http://192.168.150.61:8000")!
        // swiftlint:enable force_unwrapping

        let cache = VersionedCache(baseURL: cacheURL)

        apiClient = LawClient(baseURL: baseURL,
                              cache: cache,
                              urlSession: URLSession.shared)
    }
}

extension LawClient: ObservableObject {}
extension DocumentIdentifier: Identifiable {
    public var id: String {
        rawValue
    }
}
