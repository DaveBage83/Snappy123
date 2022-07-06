//
//  MentionMeHandler.swift
//  SnappyV2
//
//  Created by Kevin Palser on 16/06/2022.
//

import Foundation

enum MentionMeHandlerError: Swift.Error {
    case callHomeFailed(String?)
    case parameterEncoding(String?)
    case mentionMeAPICallFailed(String?)
    case unableToParseMentionMeResponse(String?)
}

extension MentionMeHandlerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .callHomeFailed(message):
            return "Call home failed with reason: \(message ?? "UKNOWN")"
        case let .parameterEncoding(message):
            return "Failed to encode paramters for Mention Me API call: \(message ?? "UKNOWN")"
        case let .mentionMeAPICallFailed(message):
            return "Mention Me API call failed: \(message ?? "UKNOWN")"
        case let .unableToParseMentionMeResponse(response):
            return "Mention Me response could not be parsed: \(response ?? "Empty")"
        }
    }
}

// Result model returned by the Mention Me API
struct MentionMeAPIResult: Decodable {
    let url: URL
    let defaultCallToAction: String?
}

// Result object returned by the MentionMeHandler
struct MentionMePostMessageConstants: Codable, Equatable {
    let actionFieldName: String
    let closeActions: [String]
    let clickTypeFieldName: String?
    let clickTypeCloseValues: [String]?
    let refereeFulfilledAction: String?
    let couponFieldName: String?
    let couponCodeFieldName: String?
}

struct MentionMeRequestResult: Equatable {
    let success: Bool
    let type: MentionMeRequest
    let webViewURL: URL?
    let buttonText: String?
    let postMessageConstants: MentionMePostMessageConstants?
    let applyCoupon: Bool?
    let openInBrowser: Bool?
}

struct MentionMeHandler {
    
    let container: DIContainer
    
    enum MentionMeHandlerPerformStep {
        case beforeCallHome
        case beforeRequestParse
        case beforeMentionMeAPICall
        case beforeMentionMeAPIResultParse
    }
    
    init(container: DIContainer) {
        self.container = container
    }

    @discardableResult
    func perform(request requestType: MentionMeRequest, businessOrderId: Int? = nil) async throws -> MentionMeRequestResult {
        
        // Reuse the previous cached result
        switch requestType {
        case .referee:
            if let cachedResult = container.appState.value.staticCacheData.mentionMeRefereeResult {
                return cachedResult
            }
        case .offer:
            if let cachedResult = container.appState.value.staticCacheData.mentionMeOfferResult {
                return cachedResult
            }
        case .dashboard:
            if let cachedResult = container.appState.value.staticCacheData.mentionMeDashboardResult {
                return cachedResult
            }
        default:
            break
        }
        
        var mentionMeErrorParams: [String: Any] = [
            "type": requestType.rawValue
        ]
        var mentionMeError: Error
        var step: MentionMeHandlerPerformStep = .beforeCallHome
        var mentionMeData: Data?
        
        do {
            // Connect to our API to tell determine what to send the Mention Me API
            let callHomeResult = try await container.services.utilityService.mentionMeCallHome(
                requestType: requestType,
                businessOrderId: businessOrderId
            )
            
            if
                let requestParameters = callHomeResult.request,
                let requestURLString = callHomeResult.requestUrl,
                let requestURL = URL(string: requestURLString),
                callHomeResult.status
            {
                step = .beforeRequestParse
                
                // Now attempt to connect to the Mention API. The ordering client app
                // has to do this directly as they collect information from its network
                // packet data to help prevent fraud/gaming.
                var request = URLRequest(url: requestURL)
                request.httpMethod = "POST"
                do {
                    request.httpBody = try requestBodyFrom(parameters: requestParameters, forDebug: false)
                } catch {
                    throw MentionMeHandlerError.parameterEncoding(error.localizedDescription)
                }
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                step = .beforeMentionMeAPICall
                
                let mentionMeRawResponse: (data: Data, urlResponse: URLResponse)
                if #available(iOS 15.0, *) {
                    mentionMeRawResponse = try await URLSession.shared.data(for: request)
                } else {
                    // Fallback on an alternative version for iOS 14
                    mentionMeRawResponse = try await URLSession.shared.legacyData(for: request)
                }
                
                // no additional parsing required for the consumer logging
                if requestType == .consumerOrder {
                    return MentionMeRequestResult(
                        success: true,
                        type: requestType,
                        webViewURL: nil,
                        buttonText: nil,
                        postMessageConstants: nil,
                        applyCoupon: nil,
                        openInBrowser: nil
                    )
                }
                
                step = .beforeMentionMeAPIResultParse
                mentionMeData = mentionMeRawResponse.data
                
                let response = try JSONDecoder().decode(MentionMeAPIResult.self, from: mentionMeRawResponse.data)
                
                let postMessageConstants: MentionMePostMessageConstants?
                if
                    let postMessageEvent = callHomeResult.postMessageEvent,
                    let actionFieldName = postMessageEvent["actionFieldName"] as? String,
                    let closeActions = postMessageEvent["closeActions"] as? [String]
                {
                    postMessageConstants = MentionMePostMessageConstants(
                        actionFieldName: actionFieldName,
                        closeActions: closeActions.map { $0.lowercased() },
                        clickTypeFieldName: postMessageEvent["clickTypeFieldName"] as? String,
                        clickTypeCloseValues: postMessageEvent["clickTypeCloseValues"] as? [String],
                        refereeFulfilledAction: postMessageEvent["refereeFulfilledAction"] as? String,
                        couponFieldName: postMessageEvent["couponFieldName"] as? String,
                        couponCodeFieldName: postMessageEvent["couponCodeFieldName"] as? String
                    )
                } else {
                    postMessageConstants = nil
                }
                
                let result = MentionMeRequestResult(
                    success: true,
                    type: requestType,
                    webViewURL: response.url,
                    buttonText: response.defaultCallToAction,
                    postMessageConstants: postMessageConstants,
                    applyCoupon: callHomeResult.applyCoupon,
                    openInBrowser: callHomeResult.openInBrowser
                )
                
                guaranteeMainThread {
                    switch requestType {
                    case .referee:
                        container.appState.value.staticCacheData.mentionMeRefereeResult = result
                    case .offer:
                        container.appState.value.staticCacheData.mentionMeOfferResult = result
                    case .dashboard:
                        container.appState.value.staticCacheData.mentionMeDashboardResult = result
                    default:
                        break
                    }
                }

                return result
                
            } else {
                if let message = callHomeResult.message {
                    mentionMeErrorParams["error"] = message
                }
                mentionMeError = MentionMeHandlerError.callHomeFailed(callHomeResult.message)
            }
            
        } catch {
            
            switch step {
            
            case .beforeCallHome:
                mentionMeError = error
                mentionMeErrorParams["error"] = error.localizedDescription
                
            case .beforeRequestParse:
                mentionMeError = MentionMeHandlerError.parameterEncoding(error.localizedDescription)
                mentionMeErrorParams["error"] = mentionMeError.localizedDescription
                
            case .beforeMentionMeAPICall:
                mentionMeError = MentionMeHandlerError.mentionMeAPICallFailed(error.localizedDescription)
                mentionMeErrorParams["error"] = mentionMeError.localizedDescription
                
            case .beforeMentionMeAPIResultParse:
                if let mentionMeData = mentionMeData {
                    mentionMeError = MentionMeHandlerError.unableToParseMentionMeResponse(String(decoding: mentionMeData, as: UTF8.self))
                } else {
                    mentionMeError = MentionMeHandlerError.unableToParseMentionMeResponse("Empty")
                }
                mentionMeErrorParams["error"] = mentionMeError.localizedDescription
            }
            
        }
        
        // Will only get here if there was an error
        container.eventLogger.sendEvent(for: .mentionMeError, with: .appsFlyer, params: mentionMeErrorParams)
        container.eventLogger.sendEvent(for: .mentionMeError, with: .firebaseAnalytics, params: mentionMeErrorParams)
        throw mentionMeError
    }
    
}
