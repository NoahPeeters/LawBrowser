//
//  main.swift
//  
//
//  Created by Noah Peeters on 30.05.20.
//

import Foundation
import CrawlerAPI
import ReactiveSwift

let crawler = CrawlerClient()

let cancellable = crawler.lawList()
    .flatMap(.concat) { SignalProducer($0) }
    .flatMap(.concat) { crawler.lawBook(for: $0) }
    .on(value: { lawBook in
        print(lawBook.identifier)
    })
    .on(failed: { error in
        print(error)
        exit(0)
    })
    .startWithCompleted {
        exit(0)
    }

RunLoop.current.run()
