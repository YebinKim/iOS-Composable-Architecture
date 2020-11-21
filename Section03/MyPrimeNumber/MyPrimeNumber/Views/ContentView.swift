//
//  ContentView.swift
//  MyPrimeNumber
//
//  Created by Yebin Kim on 2020/10/02.
//

import ComposableArchitecture
import FavoritePrimes
//import PrimeModal
import Counter
import SwiftUI

struct ContentView: View {
    
    @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    "Counter demo",
                    destination: CounterView(
//                        // MARK: View State: Focusing on view state
//                        store: self.store.view { ($0.count, $0.favoritePrimes) }
                        // MARK: View Actions: Focusing on counter actions
                        store: self.store.view(
//                            value: { ($0.count, $0.favoritePrimes) },
//                            action: { $0 }
                            // MARK: View Actions: Focusing on counter actions
//                            action: {
//                                switch $0 {
//                                case let .counter(action):
//                                    return AppAction.counter(action)
//                                case let .primeModal(action):
//                                    return AppAction.primeModal(action)
//                                }
//                            }
                            // MARK: The Point: Fixing the root app
                            value: { $0.counterView },
                            action: { .counterView($0) }
                        )
                    )
                )
                NavigationLink(
                    "Favorite primes",
                    destination: FavoritePrimesView(
//                        // MARK: View State: Focusing on view state
//                        store: self.store.view { $0.favoritePrimes }
                        // MARK: View Actions: Focusing on favorite primes actions
                        store: self.store.view(
                            value: { $0.favoritePrimes },
                            action: { AppAction.favoritePrimes($0) }
                        )
                    )
                )
            }
            .navigationBarTitle("State management")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store: Store(
                initialValue: AppState(),
                reducer: with(
                    appReducer,
                    compose(
                        logging,
                        activityFeed
                    )
                )
            )
        )
    }
}

// MARK: Utils
private func compose<A, B, C>(
    _ f: @escaping (B) -> C,
    _ g: @escaping (A) -> B
)
-> (A) -> C {
    return { (a: A) -> C in
        f(g(a))
    }
}

private func with<A, B>(_ a: A, _ f: (A) throws -> B) rethrows -> B {
    return try f(a)
}
