//
//  main.swift
//  
//
//  Created by Noah Peeters on 30.05.20.
//

import Foundation
import LawModel
import ReactiveSwift

guard CommandLine.arguments.count == 2 else {
    print("Usage: converter <base output path>")
    exit(1)
}

let path = CommandLine.arguments[1]

let converter = Converter(baseOutputURL: URL(fileURLWithPath: path))

converter.run()
    .on(failed: { error in
        print(error)
        exit(2)
    })
    .startWithCompleted {
        exit(0)
    }

//let crawler = CrawlerClient()
//
//let cancellable = crawler.lawList()
//    .flatMap(.concat) { SignalProducer($0) }
//    .filter { $0.title == "Strafgesetzbuch" }
//    .flatMap(.concat) { crawler.lawBook(for: $0) }
//    .on(value: { (lawBook: LawBook) in
//        let text = lawBook.sections[0].subsections[1].subsections[0].laws[1].text
//        try? text.write(to: URL(fileURLWithPath: "/Users/noahpeeters/Desktop/out.rtf"),
//                        atomically: false,
//                        encoding: .utf8)
//    })
//    .on(failed: { error in
//        print(error)
//        exit(0)
//    })
//    .startWithCompleted {
//        exit(0)
//    }

RunLoop.current.run()
