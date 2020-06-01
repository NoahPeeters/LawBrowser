//
//  File.swift
//  
//
//  Created by Noah Peeters on 31.05.20.
//

import Foundation
import ReactiveSwift
import Combine

extension SignalProducer {
    public func convertToPublisher() -> AnyPublisher<Value, Error> {
        let subject = PassthroughSubject<Value, Error>()

        var disposable: Disposable?

        return subject
            .handleEvents(receiveSubscription: { _ in
                disposable = self.on(failed: { subject.send(completion: .failure($0)) },
                        completed: { subject.send(completion: .finished) },
                    value: { subject.send($0) })
                    .start()
            })
            .handleEvents(receiveCancel: {
                disposable?.dispose()
            })
            .eraseToAnyPublisher()
    }
}
