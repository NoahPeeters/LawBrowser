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
    .filter { $0.title == "Strafgesetzbuch" }
    .flatMap(.concat) { crawler.lawBook(for: $0) }
    .on(value: { (lawBook: LawBook) in
        let text = lawBook.sections[0].subsections[1].subsections[0].laws[1].text
        try? text.write(to: URL(fileURLWithPath: "/Users/noahpeeters/Desktop/out.rtf"), atomically: false, encoding: .utf8)
//        print(text)
    })
    .on(failed: { error in
        print(error)
        exit(0)
    })
    .startWithCompleted {
        exit(0)
    }

RunLoop.current.run()
