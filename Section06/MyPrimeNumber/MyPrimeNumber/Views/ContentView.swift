//
//  ContentView.swift
//  MyPrimeNumber
//
//  Created by Yebin Kim on 2020/10/02.
//

import ComposableArchitecture
import FavoritePrimes
import Counter
import SwiftUI

let isInExperiment = Bool.random()

struct ContentView: View {
    
    @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            List {
                if !isInExperiment {
                    NavigationLink(
                        "Counter demo",
                        destination: CounterView(
                            store: self.store.view(
                                value: { $0.counterView },
                                action: { .counterView($0) }
                            )
                        )
                    )
                } else {
                    // MARK: The Point - Local dependencies
                    NavigationLink(
                        "Offline counter demo",
                        destination: CounterView(
                            store: self.store.view(
                                value: { $0.counterView },
                                action: { .offlineCounterView($0) }
                            )
                        )
                    )
                }
                NavigationLink(
                    "Favorite primes",
                    destination: FavoritePrimesView(
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
                ),
                environment: AppEnvironment(
                    fileClient: .live,
                    nthPrime: Counter.nthPrime,
                    offlineNthPrime: Counter.offlineNthPrime
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
