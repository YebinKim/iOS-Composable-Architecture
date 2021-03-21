//
//  PrimeModal.swift
//  PrimeModal
//
//  Created by Yebin Kim on 2020/11/01.
//

import ComposableArchitecture
import SwiftUI

public typealias PrimeModalState = (count: Int, favoritePrimes: [Int])

public enum PrimeModalAction: Equatable {
    case addFavoritePrime
    case removeFavoritePrime
}

public func primeModalReducer(
    state: inout PrimeModalState,
    action: PrimeModalAction,
    environment: Void
) -> [Effect<PrimeModalAction>] {
    switch action {
    case .addFavoritePrime:
        state.favoritePrimes.append(state.count)
        return []

    case .removeFavoritePrime:
        state.favoritePrimes.removeAll(where: { $0 == state.count })
        return []
    }
}

public struct IsPrimeModalView: View {

//    @ObservedObject var store: Store<PrimeModalState, PrimeModalAction>
    // MARK: State - View store performance
    let store: Store<PrimeModalState, PrimeModalAction>
    @ObservedObject var viewStore: ViewStore<PrimeModalState>

    // MARK: Performance - View.init/body: tracking
    public init(store: Store<PrimeModalState, PrimeModalAction>) {
        print("IsPrimeModalView.init")
        self.store = store
        self.viewStore = self.store.view(removeDuplicates: ==)
    }
    
    public var body: some View {
        print("IsPrimeModalView.body")
        return VStack {
            if isPrime(self.viewStore.value.count) {
                Text("\(self.viewStore.value.count) is prime 🎉")
                if self.viewStore.value.favoritePrimes.contains(self.viewStore.value.count) {
                    Button("Remove from favorite primes") {
                        self.store.send(.removeFavoritePrime)
                    }
                } else {
                    Button("Save to favorite primes") {
                        self.store.send(.addFavoritePrime)
                    }
                }
            } else {
                Text("\(self.viewStore.value.count) is not prime 😅")
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
