//
//  ContentView.swift
//  MyPrimeNumber
//
//  Created by Yebin Kim on 2020/10/02.
//

import ComposableArchitecture
import SwiftUI

struct ContentView: View {
    
    @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    "Counter demo",
                    destination: CounterView(
                        store: self.store
                            // MARK: View State: Focusing on view state
                            .view { ($0.count, $0.favoritePrimes) }
                    )
                )
                NavigationLink(
                    "Favorite primes",
                    destination: FavoritePrimesView(
                        store: self.store
                            // MARK: View State: Focusing on view state
                            .view { $0.favoritePrimes }
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
