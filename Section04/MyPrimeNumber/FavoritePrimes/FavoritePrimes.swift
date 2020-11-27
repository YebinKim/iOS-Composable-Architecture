//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by Yebin Kim on 2020/11/01.
//

import ComposableArchitecture
import SwiftUI

public enum FavoritePrimesAction {
    case removeFavoritePrimes(IndexSet)
    case loadedFavoritePrimes([Int])
    // MARK: Synchronous Effects - Effects in reducers
    case saveButtonTapped
}

public func favoritePrimesReducer(state: inout [Int], action: FavoritePrimesAction) -> Effect {
    switch action {
    case let .removeFavoritePrimes(indexSet):
        for index in indexSet {
            state.remove(at: index)
        }
        return {}
    case let .loadedFavoritePrimes(favoritePrimes):
        state = favoritePrimes
        return {}
    case .saveButtonTapped:
        let state = state
        return {
            let data = try! JSONEncoder().encode(state)
            let documentsPath = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            )[0]
            let documentsUrl = URL(fileURLWithPath: documentsPath)
            try! data.write(to: documentsUrl.appendingPathComponent("favorite-primes.json"))
        }
    }
}

public struct FavoritePrimesView: View {

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
                self.store.send(.removeFavoritePrimes(indexSet))
            }
        }
        .navigationBarTitle("Favorite Primes")
        // MARK: Synchronous Effects - Adding some simple side effects
        .navigationBarItems(
            trailing: HStack {
                Button("Save to disk") {
                    self.store.send(.saveButtonTapped)
                }

                Button("Load") {
                    let documentsPath = NSSearchPathForDirectoriesInDomains(
                        .documentDirectory, .userDomainMask, true
                    )[0]
                    let documentsUrl = URL(fileURLWithPath: documentsPath)
                    let favoritePrimesUrl = documentsUrl
                        .appendingPathComponent("favorite-primes.json")
                    guard
                        let data = try? Data(contentsOf: favoritePrimesUrl),
                        let favoritePrimes = try? JSONDecoder().decode([Int].self, from: data)
                    else { return }

                    self.store.send(.loadedFavoritePrimes(favoritePrimes))
                }
            }
        )
    }
}
