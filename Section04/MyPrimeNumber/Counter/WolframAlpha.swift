//
//  WolframAlpha.swift
//  MyPrimeNumber
//
//  Created by Yebin Kim on 2020/10/02.
//

import Foundation
import ComposableArchitecture

// N번째 소수 판별 API
public struct WolframAlphaResult: Decodable {

    static let wolframAlphaApiKey = "6H69Q3-828TKQJ4EP"

    let queryresult: QueryResult

    struct QueryResult: Decodable {
        let pods: [Pod]

        struct Pod: Decodable {
            let primary: Bool?
            let subpods: [SubPod]

            struct SubPod: Decodable {
                let plaintext: String
            }
        }
    }
}

import Combine

// MARK: The Point - Reusable effects: network requests
public func wolframAlpha(query: String) -> Effect<WolframAlphaResult?> {
    var components = URLComponents(string: "https://api.wolframalpha.com/v2/query")!
    components.queryItems = [
        URLQueryItem(name: "input", value: query),
        URLQueryItem(name: "format", value: "plaintext"),
        URLQueryItem(name: "output", value: "JSON"),
        URLQueryItem(name: "appid", value: WolframAlphaResult.wolframAlphaApiKey),
    ]

//    return dataTask(with: components.url(relativeTo: nil)!)
//        .decode(as: WolframAlphaResult.self)

    // MARK: - The Combine Framework and Effects: Part 2 - Refactoring asynchronous effects
    return URLSession.shared
        .dataTaskPublisher(for: components.url(relativeTo: nil)!)
        .map { data, _ in data }
        .decode(type: WolframAlphaResult?.self, decoder: JSONDecoder())
        .replaceError(with: nil)
        .eraseToEffect()
}

public func nthPrime(_ n: Int) -> Effect<Int?> {
    return wolframAlpha(query: "prime \(n)").map { result in
        result
            .flatMap {
                $0.queryresult
                    .pods
                    .first(where: { $0.primary == .some(true) })?
                    .subpods
                    .first?
                    .plaintext
            }
            .flatMap(Int.init)
    }
    .eraseToEffect()
}
