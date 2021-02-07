//
//  Wolfram.swift
//  VanillaPrimeTime
//
//  Created by Yebin Kim on 2021/02/08.
//

import Foundation

// N번째 소수 판별 API
struct WolframAlphaResult: Decodable {

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

func wolframAlpha(query: String, callback: @escaping (WolframAlphaResult?) -> Void) -> Void {
    var components = URLComponents(string: "https://api.wolframalpha.com/v2/query")!
    components.queryItems = [
        URLQueryItem(name: "input", value: query),
        URLQueryItem(name: "format", value: "plaintext"),
        URLQueryItem(name: "output", value: "JSON"),
        URLQueryItem(name: "appid", value: WolframAlphaResult.wolframAlphaApiKey),
    ]

    if let url = components.url(relativeTo: nil) {
        URLSession.shared.dataTask(with: url) { data, response, error in
          callback(
            data
              .flatMap { try? JSONDecoder().decode(WolframAlphaResult.self, from: $0) }
          )
        }
        .resume()
    }
}

func nthPrime(_ n: Int, callback: @escaping (Int?) -> Void) -> Void {
    wolframAlpha(query: "prime \(n)") { result in
        callback(
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
        )
    }
}
