//
//  Reducers.swift
//  MyPrimeNumber
//
//  Created by Yebin Kim on 2020/10/03.
//

import Foundation

// MARK: 함수형 상태 관리
// Reducer 사용 - 상태 변화가 결합된 새로운 값 반환
//enum CounterAction {
//    case decrTapped
//    case incrTapped
//}

//func counterReducer(state: AppState, action: CounterAction) -> AppState {
//    var copy = state
//    switch action {
//    case .decrTapped:
//        copy.count -= 1
//    case .incrTapped:
//        copy.count += 1
//    }
//    return copy
//}

// MARK: Ergonomics: in-out Reducers
//func counterReducer(value: inout AppState, action: CounterAction) {
//    switch action {
//    case .decrTapped:
//        value.count -= 1
//    case .incrTapped:
//        value.count += 1
//    }
//}

// MARK: 상태 변화 코드 Store로 이동
enum CounterAction {
    case decreaseCount
    case increaseCount
}

enum PrimeModalAction {
    case addFavoritePrime
    case removeFavoritePrime
}

enum FavoritePrimesAction {
    case removeFavoritePrimes(IndexSet)
}

enum AppAction {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)
    case favoritePrimes(FavoritePrimesAction)
}

func appReducer(value: inout AppState, action: AppAction) -> Void {
    switch action {
    case .counter(.decreaseCount):
        value.count -= 1

    case .counter(.increaseCount):
        value.count += 1

    case .primeModal(.addFavoritePrime):
        value.favoritePrimes.append(value.count)
        value.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(value.count)))

    case .primeModal(.removeFavoritePrime):
        value.favoritePrimes.removeAll(where: { $0 == value.count })
        value.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(value.count)))

    case let .favoritePrimes(.removeFavoritePrimes(indexSet)):
        for index in indexSet {
            let prime = value.favoritePrimes[index]
            value.favoritePrimes.remove(at: index)
            value.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(prime)))
        }
    }
}
