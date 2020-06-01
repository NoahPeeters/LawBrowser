//
//  LawListDecoder.swift
//  
//
//  Created by Noah Peeters on 30.05.20.
//

import Foundation
import XMLCoder
import GermanLaws

public class LawListDecoder {
    public let xmlDecoder = XMLDecoder(trimValueWhitespaces: true)

    public func decode(from data: Data) throws -> LawList {
        try xmlDecoder.decode(LawList.self, from: data)
    }

    public init() {}
}
