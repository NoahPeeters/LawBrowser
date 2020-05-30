//
//  GermanLawList.swift
//  
//
//  Created by Noah Peeters on 30.05.20.
//

import Foundation

public struct LawList: Codable {
    public let items: [LawListItem]

    public enum CodingKeys: String, CodingKey {
        case items = "item"
    }
}

public struct LawListItem: Codable {
    public let title: String
    public let url: URL

    public enum CodingKeys: String, CodingKey {
        case title = "title"
        case url = "link"
    }
}
