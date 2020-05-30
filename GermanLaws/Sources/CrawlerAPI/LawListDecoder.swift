//
//  LawListDecoder.swift
//  
//
//  Created by Noah Peeters on 30.05.20.
//

import Foundation
import XMLCoder

public class LawListDecoder {
    public let xmlDecoder = XMLDecoder(trimValueWhitespaces: true)

    public typealias Input = Data

    public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        try xmlDecoder.decode(type, from: data)
    }

    public init() {}
}

#if canImport(Combine)
import Combine
extension LawListDecoder: TopLevelDecoder {}
#endif
