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

    public func decode(from data: Data) throws -> GermanLawList {
        try xmlDecoder.decode(GermanLawList.self, from: data)
    }

    public init() {}
}

public struct GermanLawList: Codable {
    public let items: [GermanLawListItem]

    public enum CodingKeys: String, CodingKey {
        case items = "item"
    }
}

public struct GermanLawListItem: Codable {
    public let title: String
    public let url: URL

    public enum CodingKeys: String, CodingKey {
        case title = "title"
        case url = "link"
    }
}
