//
//  PrimeModal.swift
//  PrimeModal
//
//  Created by Yebin Kim on 2020/11/01.
//
// MARK: Reducer 모듈화: Modularizing the prime modal reducer

import ComposableArchitecture
import SwiftUI

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

// MARK: View Actions: Focusing on prime modal actions
public struct IsPrimeModalView: View {

    //@ObservedObject var store: Store<AppState, AppAction>
    // MARK: View State: Focusing on view state
//    @ObservedObject var store: Store<PrimeModalState, AppAction>
    // MARK: View Actions: Focusing on prime modal actions
    @ObservedObject var store: Store<PrimeModalState, PrimeModalAction>

    public init(store: Store<PrimeModalState, PrimeModalAction>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            if isPrime(self.store.value.count) {
                Text("\(self.store.value.count) is prime 🎉")
                if self.store.value.favoritePrimes.contains(self.store.value.count) {
                    Button("Remove from favorite primes") {
//                        self.store.send(.primeModal(.removeFavoritePrime))
                        // MARK: View Actions: Focusing on prime modal actions
                        self.store.send(.removeFavoritePrime)
                    }
                } else {
                    Button("Save to favorite primes") {
//                        self.store.send(.primeModal(.addFavoritePrime))
                        // MARK: View Actions: Focusing on prime modal actions
                        self.store.send(.addFavoritePrime)
                    }
                }
            } else {
                Text("\(self.store.value.count) is not prime 😅")
            }

        }
    }
}

// MARK: Utils
private func isPrime(_ p: Int) -> Bool {
    if p <= 1 { return false }
    if p <= 3 { return true }
    for i in 2...Int(sqrtf(Float(p))) {
        if p % i == 0 { return false }
    }
    return true
}
