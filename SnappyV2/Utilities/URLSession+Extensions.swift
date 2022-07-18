//
//  URLSession+Extensions.swift
//  SnappyV2
//
//  Created by Kevin Palser on 17/06/2022.
//

import Foundation

// based on https://www.swiftbysundell.com/articles/making-async-system-apis-backward-compatible/
@available(iOS, deprecated: 15.0, message: "Use data(for request: URLRequest, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse)")
extension URLSession {
    func legacyData(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: request) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }

                continuation.resume(returning: (data, response))
            }

            task.resume()
        }
    }
}
