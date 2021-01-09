//
//  Effects.swift
//  ComposableArchitecture
//
//  Created by vivi.kim on 2020/12/15.
//

import Foundation

//// MARK: The Point - Reusable effects: threading
//extension Effect where A == (Data?, URLResponse?, Error?) {
//    public func decode<M: Decodable>(as type: M.Type) -> Effect<M?> {
//        return self.map { data, _, _ in
//            data
//                .flatMap { try? JSONDecoder().decode(M.self, from: $0) }
//        }
//    }
//}
//
//extension Effect {
//    public func receive(on queue: DispatchQueue) -> Effect {
//        return Effect { callback in
//            self.run { a in
//                queue.async {
//                    callback(a)
//                }
//            }
//        }
//    }
//}
//
//// MARK: The Point - Reusable effects: network requests
//public func dataTask(with url: URL) -> Effect<(Data?, URLResponse?, Error?)> {
//    return Effect { callback in
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            callback((data, response, error))
//        }
//        .resume()
//    }
//}

import Combine

// MARK: - The Combine Framework and Effects: Part 2 - Pulling back reducers with publishers
extension Publisher where Failure == Never {
    public func eraseToEffect() -> Effect<Output> {
        return Effect(publisher: self.eraseToAnyPublisher())
    }
}

// MARK: - The Combine Framework and Effects: Part 2 - Finishing the architecture refactor
extension Effect {
    public static func fireAndForget(work: @escaping () -> Void) -> Effect {
        return Deferred { () -> Empty<Output, Never> in
            work()
            return Empty(completeImmediately: true)
        }
        .eraseToEffect()
    }
}
