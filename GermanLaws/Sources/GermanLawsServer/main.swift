//
//  main.swift
//  
//
//  Created by Noah Peeters on 30.05.20.
//

import Foundation
import CrawlerAPI

let crawler = CrawlerClient()

let cancellable = crawler.lawList()
    .startWithResult {
        switch $0 {
        case let .failure(error):
            print(error)
        case let .success(listItems):
            print(listItems.count)
        }
        exit(0)
    }

RunLoop.current.run()
