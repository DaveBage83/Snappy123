//
//  NetworkingHelpers.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 16/09/2021.
//

import Combine
import Foundation

// Added to switch from JSONSerialization to JSONEncoder so that the Date type
// can be encoded and dateEncodingStrategy can be set
// Take from: https://stackoverflow.com/questions/48544098/how-to-encode-dictionary-with-jsonencoder-in-swift-4
struct AnyEncodable: Encodable {

    let value: Encodable
    init(value: Encodable) {
        self.value = value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try value.encode(to: &container)
    }

}

// EncodableValue wrapper does not give the encoder the chance apply custom decoding strategies directly
// into the underlying value's encode(to:) method. With Date, this will encode the value using its default
// representation, which is as its timeIntervalSinceReferenceDate. To fix this, it needs to encode the
// underlying value in a single value container to trigger any custom encoding strategies.
// Taken from: https://stackoverflow.com/questions/48658574/jsonencoders-dateencodingstrategy-not-working
extension Encodable {
    fileprivate func encode(to container: inout SingleValueEncodingContainer) throws {
        try container.encode(self)
    }
}

func requestBodyFrom(
    parameters: [String: Any]?,
    dateEncoding: JSONEncoder.DateEncodingStrategy = AppV2Constants.API.defaultTimeEncodingStrategy,
    forDebug debug: Bool = false
    ) throws -> Data?
{
    guard let parameters = parameters else { return nil }
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = debug ? .prettyPrinted : []
    encoder.dateEncodingStrategy = dateEncoding

    return try encoder.encode(encodeToAny(parameters: parameters))
}

// recursively convert [String: Any] to [String: AnyEncodable] so that the dictionary
// can be processed by the JSONEncoder and thus avoid using JSONSerialization, which
// cannot handle Date types
func encodeToAny(parameters: [String: Any]) -> [String: AnyEncodable]? {
    return parameters.reduce(nil, { (dict, arg1) -> [String: AnyEncodable]? in
        
        let (key, value) = arg1
        var dict = dict ?? [:]
        
        if let value = value as? Encodable {
            dict[key] = AnyEncodable(value: value)
            
        // to cope with types like __NSCFString
        } else if let stringValue = value as? String {
            
            dict[key] = AnyEncodable(value: stringValue)
        } else if
            // to cope with dictionaries, e.g. /checkout/processRealexHPPConsumerData.json
            let subDictionary = value as? [String: Any],
            let anyEncodedDictionary = encodeToAny(parameters: subDictionary)
        {
            dict[key] = AnyEncodable(value: anyEncodedDictionary)
        }

        return dict
    })
}

extension Just where Output == Void {
    static func withErrorType<E>(_ errorType: E.Type) -> AnyPublisher<Void, E> {
        return withErrorType((), E.self)
    }
}

extension Just {
    static func withErrorType<E>(_ value: Output, _ errorType: E.Type
    ) -> AnyPublisher<Output, E> {
        return Just(value)
            .setFailureType(to: E.self)
            .eraseToAnyPublisher()
    }
}

extension Publisher {
    func sinkToResult(_ result: @escaping (Result<Output, Failure>) -> Void) -> AnyCancellable {
        return sink(receiveCompletion: { completion in
            switch completion {
            case let .failure(error):
                result(.failure(error))
            default: break
            }
        }, receiveValue: { value in
            result(.success(value))
        })
    }
    
    func sinkToLoadable(_ completion: @escaping (Loadable<Output>) -> Void) -> AnyCancellable {
        return sink(receiveCompletion: { subscriptionCompletion in
            if let error = subscriptionCompletion.error {
                completion(.failed(error))
            }
        }, receiveValue: { value in
            completion(.loaded(value))
        })
    }
    
    func extractUnderlyingError() -> Publishers.MapError<Self, Failure> {
        mapError {
            ($0.underlyingError as? Failure) ?? $0
        }
    }
    
    /// Holds the downstream delivery of output until the specified time interval passed after the subscription
    /// Does not hold the output if it arrives later than the time threshold
    ///
    /// - Parameters:
    ///   - interval: The minimum time interval that should elapse after the subscription.
    /// - Returns: A publisher that optionally delays delivery of elements to the downstream receiver.
    
    func ensureTimeSpan(_ interval: TimeInterval) -> AnyPublisher<Output, Failure> {
        let timer = Just<Void>(())
            .delay(for: .seconds(interval), scheduler: RunLoop.main)
            .setFailureType(to: Failure.self)
        return zip(timer)
            .map { $0.0 }
            .eraseToAnyPublisher()
    }
}

private extension Error {
    var underlyingError: Error? {
        let nsError = self as NSError
        if nsError.domain == NSURLErrorDomain && nsError.code == -1009 {
            // "The Internet connection appears to be offline."
            return self
        }
        return nsError.userInfo[NSUnderlyingErrorKey] as? Error
    }
}

extension Subscribers.Completion {
    var error: Failure? {
        switch self {
        case let .failure(error): return error
        default: return nil
        }
    }
}
