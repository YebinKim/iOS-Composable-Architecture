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

    let store: Store<AppState, AppAction>

    init(store: Store<AppState, AppAction>) {
      print("ContentView.init")
      self.store = store
    }
    
    var body: some View {
        print("ContentView.body")
        return NavigationView {
            List {
                if !isInExperiment {
                    NavigationLink(
                        "Counter demo",
                        destination: CounterView(
                            store: self.store.scope(
                                value: { $0.counterView },
                                action: { .counterView($0) }
                            )
                        )
                    )
                } else {
                    NavigationLink(
                        "Offline counter demo",
                        destination: CounterView(
                            store: self.store.scope(
                                value: { $0.counterView },
                                action: { .offlineCounterView($0) }
                            )
                        )
                    )
                }
                NavigationLink(
                    "Favorite primes",
                    destination: FavoritePrimesView(
                        store: self.store.scope(
                            value: { $0.favoritePrimesState },
                            action: { .favoritePrimes($0) }
                        )
                    )
                )

                // MARK: Performance - View.init/body: stress test
//                ForEach(Array(1...500_000), id: \.self) { value in
//                    Text("\(value)")
//                }
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
                // MARK: Ergonomic State Management: Part 1 - Updating the app's modules
//                reducer: with(
//                    appReducer,
//                    compose(
//                        logging,
//                        activityFeed
//                    )
//                ),
                reducer: appReducer
                    .activityFeed(),
//                .logging()
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
