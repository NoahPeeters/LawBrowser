//
//  Publisher+Start.swift
//  LawBrowser
//
//  Created by Noah Peeters on 01.06.20.
//  Copyright © 2020 Noah Peeters. All rights reserved.
//

import Combine
import SwiftUI

extension Publisher {
    /// Adds an anonymous subscriber to the publisher. The subscription
    /// will automatically be kept alive until the publisher finishes or
    /// is manually cancelled. The returned cancellable doesn't have to be
    /// retained by the caller.
    @discardableResult public func start() -> AnyCancellable {
        var cancellable: AnyCancellable!

        cancellable = handleEvents(receiveCancel: {
            cancellable = nil
        }).sink(receiveCompletion: { _ in
            cancellable = nil
        }, receiveValue: { _ in  })

        return cancellable
    }
}

extension Publisher {

    /// Subscribes to the publisher and assigns any output or errors to the provided bindings.
    /// Sets the provided `isBusy` binding to true until the publisher completes. The method
    /// returns an AnyCancellable to explicitly cancel the subscription. Note that the subscription
    /// will NOT be automatically cancelled if you discard the AnyCancellable.
    @discardableResult public func bind(output: Binding<Output?> = .constant(nil),
                                        failure: Binding<Failure?> = .constant(nil),
                                        isBusy: Binding<Bool> = .constant(false)) -> AnyCancellable {
        handleEvents(
            receiveSubscription: { _ in
                isBusy.wrappedValue = true
                failure.wrappedValue = nil
            },
            receiveOutput: { value in output.wrappedValue = value },
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    failure.wrappedValue = error
                }
                isBusy.wrappedValue = false
            },
            receiveCancel: {
                isBusy.wrappedValue = false
            }
        ).start()
    }

    /// Subscribes to the publisher and assigns any output or errors to the provided bindings.
    /// Sets the provided `isBusy` binding to true until the publisher completes. The method
    /// returns an AnyCancellable to explicitly cancel the subscription. Note that the subscription
    /// will NOT be automatically cancelled if you discard the AnyCancellable.
    @discardableResult public func bind(output: Binding<Output>,
                                        failure: Binding<Failure?> = .constant(nil),
                                        isBusy: Binding<Bool> = .constant(false)) -> AnyCancellable {
        self.bind(output: Binding<Output?>(output),
                  failure: failure,
                  isBusy: isBusy)
    }
}
