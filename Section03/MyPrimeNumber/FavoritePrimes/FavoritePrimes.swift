//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by Yebin Kim on 2020/11/01.
//
// MARK: Reducer 모듈화: Modularizing the favorite primes reducer

import ComposableArchitecture
import SwiftUI

public enum FavoritePrimesAction {
    case removeFavoritePrimes(IndexSet)
}

public func favoritePrimesReducer(state: inout [Int], action: FavoritePrimesAction) -> Void {
    switch action {
    case let .removeFavoritePrimes(indexSet):
        for index in indexSet {
            state.remove(at: index)
        }
    }
}

// MARK: View Actions: Extracting our first modular view
public struct FavoritePrimesView: View {

    //@ObservedObject var store: Store<AppState, AppAction>
    // MARK: View State: Focusing on view state
    //    @ObservedObject var store: Store<[Int], AppAction>
    // MARK: View Actions: Focusing on favorite primes actions
    @ObservedObject var store: Store<[Int], FavoritePrimesAction>

    public init(store: Store<[Int], FavoritePrimesAction>) {
        self.store = store
    }

    public var body: some View {
        List {
            ForEach(self.store.value, id: \.self) { prime in
                Text("\(prime)")
            }
            .onDelete { indexSet in
                //                self.store.send(.favoritePrimes(.removeFavoritePrimes(indexSet)))
                // MARK: View Actions: Focusing on favorite primes actions
                self.store.send(.removeFavoritePrimes(indexSet))
            }
        }
        .navigationBarTitle("Favorite Primes")
    }
}
