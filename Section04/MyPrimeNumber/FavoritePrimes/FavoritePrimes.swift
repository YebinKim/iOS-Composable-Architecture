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
    case loadButtonTapped
}

// MARK: Unidirectional Effects - Working with our new effects
public func favoritePrimesReducer(state: inout [Int], action: FavoritePrimesAction) -> [Effect<FavoritePrimesAction>] {
    switch action {
    case let .removeFavoritePrimes(indexSet):
        for index in indexSet {
            state.remove(at: index)
        }
        return []

    case let .loadedFavoritePrimes(favoritePrimes):
        state = favoritePrimes
        return []

    case .saveButtonTapped:
        let state = state
        return [saveEffect(favoritePrimes: state)]

    case .loadButtonTapped:
        return [loadEffect()]
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
                // MARK: Unidirectional Effects - Synchronous effects that produce results
                Button("Load") {
                    self.store.send(.loadButtonTapped)
                }
            }
        )
    }
}

// MARK: The Point - Getting everything building again
private func saveEffect(favoritePrimes: [Int]) -> Effect<FavoritePrimesAction> {
    return Effect { _ in
        let data = try! JSONEncoder().encode(favoritePrimes)
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentsUrl = URL(fileURLWithPath: documentsPath)
        let favoritePrimesUrl = documentsUrl.appendingPathComponent("favorite-primes.json")
        try! data.write(to: favoritePrimesUrl)
    }
}

private func loadEffect() -> Effect<FavoritePrimesAction> {
    return Effect { closure in
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
        closure(.loadedFavoritePrimes(favoritePrimes))
    }
}
