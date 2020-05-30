//
//  LawsDecoder.swift
//  
//
//  Created by Noah Peeters on 30.05.20.
//

import Foundation
import XMLCoder
import Combine

public class LawsDecoder: TopLevelDecoder {
    public let xmlDecoder: XMLDecoder = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        let decoder = XMLDecoder(trimValueWhitespaces: true)
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()

    public typealias Input = Data

    public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        try xmlDecoder.decode(type, from: data)
    }

    public init() {}
}
