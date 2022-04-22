//
//  Publisher+Extensions.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 04/08/2021.
//

import Combine

extension Publisher where Failure == Never {
    
    /// Use this, most of the time, instead of .assign, as it keeps a weak reference
    public func assignWeak<Root>(to keyPath: ReferenceWritableKeyPath<Root, Output>, on object: Root) -> AnyCancellable where Root: AnyObject {
        sink { [weak object] (value) in
            guard let object = object else { return }
            object[keyPath: keyPath] = value
        }
    }
}

extension Publisher where Output == Void {
    func sink(receiveCompletion: @escaping ((Subscribers.Completion<Failure>) -> Void)) -> AnyCancellable {
        sink(receiveCompletion: receiveCompletion, receiveValue: {})
    }
}

extension Publishers {
    struct MissingOutputError: Error {}
}

extension Publisher {
    
    /// Extension based on https://www.swiftbysundell.com/articles/connecting-async-await-with-other-swift-code/ to use
    /// async/await with Combine Publishers
    func singleOutput() async throws -> Output {
        if #available(iOS 15, *) {
            for try await output in values {
                // Since we're immediately returning upon receiving
                // the first output value, that'll cancel our
                // subscription to the current publisher:
                return output
            }
            throw Publishers.MissingOutputError()
        } else {
            var cancellable: AnyCancellable?
            var didReceiveValue = false

            return try await withCheckedThrowingContinuation { continuation in
                cancellable = sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        case .finished:
                            if !didReceiveValue {
                                continuation.resume(
                                    throwing: Publishers.MissingOutputError()
                                )
                            }
                        }
                    },
                    receiveValue: { value in
                        guard !didReceiveValue else { return }

                        didReceiveValue = true
                        cancellable?.cancel()
                        continuation.resume(returning: value)
                    }
                )
            }
        }
    }
    
    // Lifted from: https://www.swiftbysundell.com/articles/calling-async-functions-within-a-combine-pipeline/
    // Calling async functions within Combine pipelines
    func asyncMap<T>(
        _ transform: @escaping (Output) async -> T
    ) -> Publishers.FlatMap<Future<T, Never>, Self> {
        flatMap { value in
            Future { promise in
                Task {
                    let output = await transform(value)
                    promise(.success(output))
                }
            }
        }
    }
    
    func asyncMap<T>(
        _ transform: @escaping (Output) async throws -> T
    ) -> Publishers.FlatMap<Future<T, Error>, Self> {
        flatMap { value in
            Future { promise in
                Task {
                    do {
                        let output = try await transform(value)
                        promise(.success(output))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
    
    func asyncMap<T>(
            _ transform: @escaping (Output) async throws -> T
    ) -> Publishers.FlatMap<Future<T, Error>,
            Publishers.SetFailureType<Self, Error>> {
        flatMap { value in
            Future { promise in
                Task {
                    do {
                        let output = try await transform(value)
                        promise(.success(output))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
}
