//
//  NetworkHandler.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 16/09/2021.
//

import Combine
import Foundation

// The UserApi is the object that will make authenticated network requests.

struct NetworkHandler {
    
    private let authenticator: NetworkAuthenticator
    private let debugTrace: Bool
        
    init(authenticator: NetworkAuthenticator, debugTrace: Bool = false) {
        self.authenticator = authenticator
        self.debugTrace = debugTrace
    }

    func request<T: Decodable>(url: URL, method: String = "POST", parameters: [String: Any]? = nil) -> AnyPublisher<T, Error> {
        
        let tokenSubject = authenticator.tokenSubject()
        var authenticationCancellable: AnyCancellable?
        
        return tokenSubject
            .flatMap({ token -> AnyPublisher<T, Error> in
                
                if let accessToken = token.accessToken {
                    
                    // flatMap over the CurrentValueSubject to kick off a network call whenever we receive a token
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = method
                    request.httpBody = requestBodyFrom(parameters: parameters, forDebug: debugTrace)
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    let config = URLSessionConfiguration.default
                    let bearerString = "Bearer " + accessToken
                    
                    // https://ampersandsoftworks.com/posts/bearer-authentication-nsurlsession/
                    request.setValue(bearerString, forHTTPHeaderField: "Authentication")
                    config.httpAdditionalHeaders = ["Authorization" : bearerString]
                    
                    // just in case this starts failing for because Apple decides to remove
                    // the above workaround
                    request.setValue(bearerString, forHTTPHeaderField: "Alt-Bearer")
                    
                    let session = URLSession(configuration: config)
                    
                    if debugTrace {
                        print("REQUEST: " + url.absoluteString)
                        if
                            let httpBody = request.httpBody,
                            let jsonText = String(data: httpBody, encoding: String.Encoding.utf8)
                        {
                            print(jsonText)
                        }
                        print("Access Token: " + accessToken)
                    }
                    
                    return session.dataTaskPublisher(for: request)
                        .mapError({ $0 as Error })
                        .flatMap({ result -> AnyPublisher<T, Error> in
                            
                            if debugTrace {
                                print("RESULT: " + url.absoluteString)
                                if
                                    let object = try? JSONSerialization.jsonObject(with: result.data, options: []),
                                    let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
                                    let jsonText = String(data: data, encoding: String.Encoding.utf8)
                                {
                                    print(jsonText)
                                }
                            }
                            
                            let decoder = JSONDecoder()
                            
                            if let httpResponse = result.response as? HTTPURLResponse {
                                
                                if debugTrace {
                                    print("Status Code: \(httpResponse.statusCode)")
                                }

                                if httpResponse.statusCode == 401 || (httpResponse.statusCode == 400 && token.refreshToken != nil) {
                                
                                    // If the result of the data task that’s created in this flatMap has a 401 status code,
                                    // we do not want to forward this value to subscribers. Instead, we want to pretend we
                                    // never received this value and kick off a token refresh and subsequently retry the
                                    // network request.
                                    self.authenticator.refreshToken(using: tokenSubject, cancellable: &authenticationCancellable)
                                    return Empty().eraseToAnyPublisher()
                                    
                                } else if (200...299).contains(httpResponse.statusCode) == false {
                                    
                                    if let apiError = try? decoder.decode(APIError.self, from: result.data) {
                                        return Fail(outputType: T.self, failure: apiError)
                                            .eraseToAnyPublisher()
                                    }
                                }

                            }
                            
                            do {
                                let model = try decoder.decode(T.self, from: result.data)
                                return Just(model)
                                    .setFailureType(to: Error.self)
                                    .eraseToAnyPublisher()
                            } catch {
                                
                                if debugTrace {
                                    print("JSON Decode Error: " + error.localizedDescription)
                                }
                                
                                return Fail(outputType: T.self, failure: error)
                                    .eraseToAnyPublisher()
                            }
                        })
                        .eraseToAnyPublisher()
                
                } else {
                    // starting with no access token so we need aquire one
                    self.authenticator.refreshToken(using: tokenSubject, cancellable: &authenticationCancellable)
                    return Empty().eraseToAnyPublisher()
                }
            })
            .handleEvents(receiveOutput: { _ in
                tokenSubject.send(completion: .finished)
            }, receiveCancel: {
                authenticationCancellable?.cancel()
            })
            .eraseToAnyPublisher()
    }
    
    func requestURL(_ url: URL, method: String = "POST", parameters: [String: Any]? = nil) -> AnyPublisher<Data, Error> {
        
        let tokenSubject = authenticator.tokenSubject(withDebugTrace: debugTrace)
        var authenticationCancellable: AnyCancellable?
        
        return tokenSubject
            .flatMap({ token -> AnyPublisher<Data, Error> in
                
                if let accessToken = token.accessToken {
                    
                    // flatMap over the CurrentValueSubject to kick off a network call whenever we receive a token
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = method
                    request.httpBody = requestBodyFrom(parameters: parameters, forDebug: debugTrace)
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    let config = URLSessionConfiguration.default
                    let bearerString = "Bearer " + accessToken
                    
                    // https://ampersandsoftworks.com/posts/bearer-authentication-nsurlsession/
                    request.setValue(bearerString, forHTTPHeaderField: "Authentication")
                    config.httpAdditionalHeaders = ["Authorization" : bearerString]
                    
                    // just in case this starts failing for because Apple decides to remove
                    // the above workaround
                    request.setValue(bearerString, forHTTPHeaderField: "Alt-Bearer")
                    
                    let session = URLSession(configuration: config)
                    
                    if debugTrace {
                        print("REQUEST: " + url.absoluteString)
                        if
                            let httpBody = request.httpBody,
                            let jsonText = String(data: httpBody, encoding: String.Encoding.utf8)
                        {
                            print(jsonText)
                        }
                        print("Access Token: " + accessToken)
                    }
                    
                    return session.dataTaskPublisher(for: request)
                        .mapError({ $0 as Error })
                        .flatMap({ result -> AnyPublisher<Data, Error> in
                            
                            if debugTrace {
                                print("RESULT: " + url.absoluteString)
                                if
                                    let object = try? JSONSerialization.jsonObject(with: result.data, options: []),
                                    let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
                                    let jsonText = String(data: data, encoding: String.Encoding.utf8)
                                {
                                    print(jsonText)
                                }
                            }
                            
                            if let httpResponse = result.response as? HTTPURLResponse {
                                
                                if debugTrace {
                                    print("Status Code: \(httpResponse.statusCode)")
                                }

                                if httpResponse.statusCode == 401 || (httpResponse.statusCode == 400 && token.refreshToken != nil) {
                                
                                    // If the result of the data task that’s created in this flatMap has a 401 status code,
                                    // we do not want to forward this value to subscribers. Instead, we want to pretend we
                                    // never received this value and kick off a token refresh and subsequently retry the
                                    // network request.
                                    self.authenticator.refreshToken(using: tokenSubject, cancellable: &authenticationCancellable)
                                    return Empty().eraseToAnyPublisher()
                                    
                                } else if (200...299).contains(httpResponse.statusCode) == false {
                                    
                                    let decoder = JSONDecoder()
                                    
                                    if let apiError = try? decoder.decode(APIError.self, from: result.data) {
                                        return Fail(outputType: Data.self, failure: apiError)
                                            .eraseToAnyPublisher()
                                    }
                                }
                            }
                            
                            return Just(result.data)
                                .setFailureType(to: Error.self)
                                .eraseToAnyPublisher()
                        })
                        .eraseToAnyPublisher()
                
                } else {
                    // starting with no access token so we need aquire one
                    self.authenticator.refreshToken(using: tokenSubject, cancellable: &authenticationCancellable)
                    return Empty().eraseToAnyPublisher()
                }
            })
            .handleEvents(receiveOutput: { _ in
                tokenSubject.send(completion: .finished)
            }, receiveCancel: {
                authenticationCancellable?.cancel()
            })
            .eraseToAnyPublisher()
    }
    
    // a convenience wrapper that can also set the debug trace
    func signIn(with provider: String? = nil, parameters: [String: Any]) -> AnyPublisher<Bool, Error> {
        return authenticator.signIn(
            with: provider,
            parameters: parameters,
            withDebugTrace: debugTrace
        )
    }
    
}
