//
//  PrimeModal.swift
//  PrimeModal
//
//  Created by Yebin Kim on 2020/11/01.
//
// MARK: Reducer 모듈화: Modularizing the prime modal reducer

// AppState 중 필요한 속성만 의존하기 위한 상태타입 생성
//public struct PrimeModalState {
//    public var count: Int
//    public var favoritePrimes: [Int]
//
//    public init(count: Int, favoritePrimes: [Int]) {
//        self.count = count
//        self.favoritePrimes = favoritePrimes
//    }
//}
public typealias PrimeModalState = (count: Int, favoritePrimes: [Int])

public enum PrimeModalAction {
    case addFavoritePrime
    case removeFavoritePrime
}

public func primeModalReducer(state: inout PrimeModalState, action: PrimeModalAction) -> Void {
    switch action {
    case .addFavoritePrime:
        state.favoritePrimes.append(state.count)

    case .removeFavoritePrime:
        state.favoritePrimes.removeAll(where: { $0 == state.count })
    }
}
